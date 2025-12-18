<?php
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../config/database.php';

$scriptPath = dirname($_SERVER['SCRIPT_NAME']);
$basePath = str_replace('/public', '', $scriptPath);
if ($basePath === '/' || $basePath === '') $basePath = '';

$pdo = getDbConnection();

$flash = getFlashMessage();
$error = '';
$success = '';
if (is_array($flash)) {
    if (($flash['type'] ?? '') === 'error') $error = $flash['message'] ?? '';
    if (($flash['type'] ?? '') === 'success') $success = $flash['message'] ?? '';
}

$search     = trim($_GET['q'] ?? '');
$sort       = $_GET['sort'] ?? '';
$filterDept = $_GET['dept'] ?? '';
$filterProg = $_GET['program'] ?? '';
$filterYear = $_GET['yearLevel'] ?? '';
$dateFrom   = $_GET['from'] ?? '';
$dateTo     = $_GET['to'] ?? '';

$page = max(1, (int)($_GET['page'] ?? 1));
$perPage = 15;
$offset = ($page - 1) * $perPage;

$where = [];
$params = [];

$consultDateWhere = "";
if ($dateFrom !== '') {
    $consultDateWhere .= " AND c.date >= :dateFrom";
    $params[':dateFrom'] = $dateFrom;
}
if ($dateTo !== '') {
    $consultDateWhere .= " AND c.date <= :dateTo";
    $params[':dateTo'] = $dateTo;
}

if ($search !== "") {
    $where[] = "(CONCAT(u.firstname, ' ', u.lastname) LIKE :qName OR u.student_id LIKE :qId)";
    $params[':qName'] = "%$search%";
    $params[':qId']   = "%$search%";
}

if ($filterDept !== "") {
    $where[] = "u.department = :dept";
    $params[':dept'] = $filterDept;
}

if ($filterProg !== "") {
    $where[] = "u.program = :program";
    $params[':program'] = $filterProg;
}

if ($filterYear !== "") {
    $where[] = "u.year_level = :yearLevel";
    $params[':yearLevel'] = $filterYear;
}

$whereSql = "";
if (count($where) > 0) {
    $whereSql = "WHERE " . implode(" AND ", $where);
}

$orderSql = "ORDER BY u.lastname ASC";
switch ($sort) {
    case "name_asc":  $orderSql = "ORDER BY u.lastname ASC, u.firstname ASC"; break;
    case "name_desc": $orderSql = "ORDER BY u.lastname DESC, u.firstname DESC"; break;
    case "id_asc":    $orderSql = "ORDER BY u.student_id ASC"; break;
    case "id_desc":   $orderSql = "ORDER BY u.student_id DESC"; break;
    case "visits_asc":  $orderSql = "ORDER BY visits_count ASC"; break;
    case "visits_desc": $orderSql = "ORDER BY visits_count DESC"; break;
    case "lastvisit_asc":  $orderSql = "ORDER BY last_visit ASC"; break;
    case "lastvisit_desc": $orderSql = "ORDER BY last_visit DESC"; break;
}

$sql = "
SELECT 
    pr.recordId,
    pr.studentId AS student_id_fk,
    u.student_id,
    u.firstname,
    u.lastname,
    u.department,
    u.program,
    u.year_level,

    (
        SELECT MAX(c2.date)
        FROM consultationRecord c2
        WHERE c2.recordId = pr.recordId
        " . ($dateFrom ? " AND c2.date >= :dateFrom " : "") . "
        " . ($dateTo ? " AND c2.date <= :dateTo " : "") . "
    ) AS last_visit,

    (
        SELECT COUNT(*)
        FROM consultationRecord c3
        WHERE c3.recordId = pr.recordId
        " . ($dateFrom ? " AND c3.date >= :dateFrom " : "") . "
        " . ($dateTo ? " AND c3.date <= :dateTo " : "") . "
    ) AS visits_count,

    pr.created_at

FROM patientRecord pr
JOIN users u ON u.student_id = pr.studentId
$whereSql
$orderSql
LIMIT :limit OFFSET :offset
";

$stmt = $pdo->prepare($sql);

$params[':limit'] = (int)$perPage;
$params[':offset'] = (int)$offset;

foreach ($params as $k => $v) {
    if (in_array($k, [':limit', ':offset'])) {
        $stmt->bindValue($k, $v, PDO::PARAM_INT);
    } else {
        $stmt->bindValue($k, $v, PDO::PARAM_STR);
    }
}

$stmt->execute();
$items = $stmt->fetchAll(PDO::FETCH_ASSOC);

$recordIds = array_map(function($r){ return (int)$r['recordId']; }, $items);

$studentIds = [];
foreach ($items as $r) {
    // use the student_id column (from users) to query allergyInfo which is keyed by studentId
    $studentIds[] = $r['student_id'];
}
$recordIds = array_values(array_unique($recordIds));
$studentIds = array_values(array_unique($studentIds));

$details = []; // keyed by recordId

if (!empty($recordIds)) {

    // 1) allergyInfo (keyed by studentId)
    if (!empty($studentIds)) {
        $inPlaceholders = implode(',', array_fill(0, count($studentIds), '?'));
        $sqlAll = "SELECT * FROM allergyInfo WHERE studentId IN ($inPlaceholders)";
        $st = $pdo->prepare($sqlAll);
        foreach ($studentIds as $i => $sid) $st->bindValue($i+1, $sid, PDO::PARAM_STR);
        $st->execute();
        $allergyRows = $st->fetchAll(PDO::FETCH_ASSOC);
        $allergyByStudent = [];
        foreach ($allergyRows as $a) $allergyByStudent[$a['studentId']] = $a;
    } else {
        $allergyByStudent = [];
    }

    // 2) dentalRecord
    $inPlaceholders = implode(',', array_fill(0, count($recordIds), '?'));
    $sqlDent = "SELECT * FROM dentalRecord WHERE recordId IN ($inPlaceholders) ORDER BY date DESC";
    $st = $pdo->prepare($sqlDent);
    foreach ($recordIds as $i => $rid) $st->bindValue($i+1, $rid, PDO::PARAM_INT);
    $st->execute();
    $dentalRows = $st->fetchAll(PDO::FETCH_ASSOC);
    $dentalByRecord = [];
    foreach ($dentalRows as $d) $dentalByRecord[$d['recordId']][] = $d;

    // 3) medicalCertificate
    $sqlCert = "SELECT * FROM medicalCertificate WHERE recordId IN ($inPlaceholders) ORDER BY dateIssued DESC";
    $st = $pdo->prepare($sqlCert);
    foreach ($recordIds as $i => $rid) $st->bindValue($i+1, $rid, PDO::PARAM_INT);
    $st->execute();
    $certRows = $st->fetchAll(PDO::FETCH_ASSOC);
    $certByRecord = [];
    foreach ($certRows as $c) $certByRecord[$c['recordId']][] = $c;

    // 4) consultationRecord
    $sqlCon = "SELECT * FROM consultationRecord WHERE recordId IN ($inPlaceholders) ORDER BY date DESC";
    $st = $pdo->prepare($sqlCon);
    foreach ($recordIds as $i => $rid) $st->bindValue($i+1, $rid, PDO::PARAM_INT);
    $st->execute();
    $consultRows = $st->fetchAll(PDO::FETCH_ASSOC);
    $consultByRecord = [];
    $consultationIds = [];
    foreach ($consultRows as $c) {
        $consultByRecord[$c['recordId']][] = $c;
        $consultationIds[] = $c['consultationId'];
    }
    $consultationIds = array_values(array_unique($consultationIds));

    // 5) assessment (by consultationId)
    $assessmentByConsult = [];
    if (!empty($consultationIds)) {
        $inCons = implode(',', array_fill(0, count($consultationIds), '?'));
        $sqlAss = "SELECT * FROM assessment WHERE consultationId IN ($inCons) ORDER BY created_at DESC";
        $st = $pdo->prepare($sqlAss);
        foreach ($consultationIds as $i => $cid) $st->bindValue($i+1, $cid, PDO::PARAM_INT);
        $st->execute();
        $assRows = $st->fetchAll(PDO::FETCH_ASSOC);
        foreach ($assRows as $a) $assessmentByConsult[$a['consultationId']][] = $a;
    }

    // 6) prescription (by consultationId)
    $prescByConsult = [];
    if (!empty($consultationIds)) {
        $inCons = implode(',', array_fill(0, count($consultationIds), '?'));
        $sqlPres = "SELECT * FROM prescription WHERE consultationId IN ($inCons) ORDER BY created_at DESC";
        $st = $pdo->prepare($sqlPres);
        foreach ($consultationIds as $i => $cid) $st->bindValue($i+1, $cid, PDO::PARAM_INT);
        $st->execute();
        $presRows = $st->fetchAll(PDO::FETCH_ASSOC);
        foreach ($presRows as $p) $prescByConsult[$p['consultationId']][] = $p;
    }

    foreach ($items as $it) {
        $rid = (int)$it['recordId'];
        $sid = $it['student_id'] ?? null;
        $details[$rid] = [
            'student' => [
                'student_id' => $it['student_id'] ?? '',
                'firstname' => $it['firstname'] ?? '',
                'lastname' => $it['lastname'] ?? '',
                'department' => $it['department'] ?? '',
                'program' => $it['program'] ?? '',
                'year_level' => $it['year_level'] ?? '',
                'last_visit' => $it['last_visit'] ?? null,
                'visits_count' => (int)($it['visits_count'] ?? 0),
            ],
            'allergy' => $allergyByStudent[$sid] ?? null,
            'dental' => $dentalByRecord[$rid] ?? [],
            'certificates' => $certByRecord[$rid] ?? [],
            'consultations' => []
        ];

        if (!empty($consultByRecord[$rid])) {
            foreach ($consultByRecord[$rid] as $c) {
                $cid = $c['consultationId'];
                $c['assessments'] = $assessmentByConsult[$cid] ?? [];
                $c['prescriptions'] = $prescByConsult[$cid] ?? [];
                $details[$rid]['consultations'][] = $c;
            }
        }
    }
}

// Total rows for pagination (count)
$countSql = "
SELECT COUNT(DISTINCT pr.recordId) as cnt
FROM patientRecord pr
JOIN users u ON u.student_id = pr.studentId
LEFT JOIN consultationRecord c ON c.recordId = pr.recordId
$consultDateWhere
$whereSql
";
$countStmt = $pdo->prepare($countSql);

foreach ($params as $k => $v) {
    if ($k === ':limit' || $k === ':offset') continue;
    $countStmt->bindValue($k, $v, PDO::PARAM_STR);
}
$countStmt->execute();
$totalRows = (int)$countStmt->fetchColumn();
$totalPages = (int)ceil($totalRows / $perPage);

// FILTER SOURCES (now from users table)
$departments = $pdo->query("SELECT DISTINCT department FROM users ORDER BY department ASC")->fetchAll(PDO::FETCH_COLUMN);
$programs    = $pdo->query("SELECT DISTINCT program FROM users ORDER BY program ASC")->fetchAll(PDO::FETCH_COLUMN);
$years       = $pdo->query("SELECT DISTINCT year_level FROM users ORDER BY year_level ASC")->fetchAll(PDO::FETCH_COLUMN);

function h($value) {
    return htmlspecialchars($value ?? '', ENT_QUOTES, 'UTF-8');
}

function buildPageLink($p) {
    $qs = $_GET;
    $qs['page'] = $p;
    return 'clinic-patient-records.php?' . http_build_query($qs);
}

// JSON-encode details for client-side use. Use HEX_* flags to reduce XSS risk in inline JSON.
$details_json = json_encode($details, JSON_HEX_TAG|JSON_HEX_AMP|JSON_HEX_APOS|JSON_HEX_QUOT);
if ($details_json === false) $details_json = '{}';
?>
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8" />
<title>JoseniCare | Patient Records</title>
<meta name="viewport" content="width=device-width, initial-scale=1" />

<link rel="preload" href="<?php echo $basePath; ?>/dist/css/adminlte.css" as="style" />
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fontsource/source-sans-3@5.0.12/index.css" media="print" onload="this.media='all'">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/overlayscrollbars@2.11.0/styles/overlayscrollbars.min.css" />
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css" />
<link rel="stylesheet" href="<?php echo $basePath; ?>/dist/css/adminlte.css" />

<style>
/* MAIN CONTAINER */
body { background: #f5f6f8; margin:0; }
.page { display:flex; min-height:100vh; }

/* SIDEBAR */
.sidebar {
    width: 4%;
    background: #171821;
    padding: 10px;
    display: flex;
    flex-direction: column;
    align-items: center;
}

.sidebar-logo img {
    width: 58px;
    height: 58px;
    padding: 5px;
    border-radius: 14px;
    margin-bottom: 28px;
}

.sidebar-nav {
    display: flex;
    flex-direction: column;
    gap: 50px;
    align-items: center;
}

.nav-item {
    width: 40px;
    height: 40px;
    background: #262b27;
    border-radius: 14px;
    display: flex;
    justify-content: center;
    align-items: center;
    color: #9cad9f;
    font-size: 22px;
    transition: 0.25s;
    border: 2px solid transparent;
}

.nav-item:hover {
    background: #2e3430;
    border-color: #3fe17b;
    color: #c1e8c9;
}

.nav-item.active {
    border-color: #3fe17b;
    color: #3fe17b;
    background: #2b312e;
}

/* MAIN CONTENT */
.main-content { flex:1; padding:36px; }
.title { font-size:56px; font-weight:800; color:#123c24; margin-bottom:12px; }

/* SEARCH BAR */
.search-row {
    display:flex;
    gap:12px;
    align-items:center;
    margin:28px 0;
    flex-wrap:wrap;
    width: 100%;
}

.search-row input[type="text"] {
    padding:12px;
    flex: 1;
    border-radius:10px;
    border:2px solid #dcdcdc;
    height: 40px;
    font-size: 16px;
}

.btn-search {
    padding: 5px 18px;
    background: #34703A;
    color: #fff;
    border-radius: 7px;
    border: none;
    width: 10rem;
    height: 35px;
    font-weight: 500;
}

.btn-reset {
    padding: 5px 18px;
    background: #8B0303;
    border-radius: 7px;
    width: 10rem;
    height: 35px;
    color: #fff;
    text-decoration: none;
    text-align: center;
}

/* FILTER ROW */
.filter-row {
    display: flex;
    gap: 10px;
    align-items: center;
    margin-top: -10px;
    margin-bottom: 20px;
    flex-wrap: wrap;
}

.btn-grey {
    padding: 5px 18px;
    background: #efefef;
    border-radius: 7px;
    border: 1px solid #d6d6d6;
    width: 10rem;
    height: 35px;
    color:#000000;
}

.pill {
    padding:6px 6px;
    background:#fff;
    border-radius:6px;
    border:1px solid #ddd;
}

.small { font-size:13px; color:#666; }

/* TABLE */
.table-wrap {
    background:#fff;
    padding:12px 18px;
    border-radius:12px;
    box-shadow:0 6px 18px rgba(0,0,0,0.06);
}

.records { width:100%; border-collapse:collapse; text-align:center; }
.records th { padding:12px; background:#fafafa; font-weight:700; }
.records td { padding:12px; border-bottom:1px solid #eee; }
.records tbody tr:hover { background:#f3fff4; cursor:pointer; }

/* PAGINATION */
.pagination { margin-top:12px; display:flex; gap:8px; align-items:center; }

/* POP UP MODALS */
.modal-title {
    font-weight: 700;
    font-size: 35px;
    color: #153021;
    text-align: center;
    width: 100%;
}

.info-header {
    color: #34703A;
    font-size: 22px;
    font-weight: 700;
}

.info-header .info-details {
    margin-left: 100px;
}

#alertBox {
    background:#FFF2F2;
    border: 2px solid #703434;
    color: #8B0303;
    font-size: 18px;
    padding-top: 0;
}

#alertList {
    color: #4d0202ff;
    font-size: 16px;
}

/* small table inside modal */
.small-table { width:100%; border-collapse: collapse; margin-top: 8px; }
.small-table th, .small-table td { padding:6px; border:1px solid #eee; text-align:left; font-size:14px; }
</style>
</head>

<body>

<div class="page">
    <!-- SIDEBAR -->
    <aside class="sidebar">
        <div class="sidebar-logo">
            <img src="../dist/assets/img/josecare-logo.png" alt="JoseniCare Logo">
        </div>

        <nav class="sidebar-nav">
            <a href="clinic-dashboard.php" class="nav-item"><i class="bi bi-grid-fill"></i></a>
            <a href="clinic-appointments.php" class="nav-item"><i class="bi bi-calendar2-check"></i></a>
            <a href="clinic-patient-records.php" class="nav-item active"><i class="bi bi-folder2-open"></i></a>
            <a href="clinic-survey.php" class="nav-item"><i class="bi bi-clipboard-pulse"></i></a>
            <a href="clinic-inventory.php" class="nav-item"><i class="bi bi-box-seam"></i></a>
            <a href="clinic-settings.php" class="nav-item"><i class="bi bi-gear"></i></a>
        </nav>
    </aside>


    <!-- MAIN CONTENT -->
    <div class="main-content">
        <div class="title">PATIENT RECORDS</div>

        <?php if ($error): ?>
            <div class="alert alert-danger"><?= h($error) ?></div>
        <?php endif; ?>
        <?php if ($success): ?>
            <div class="alert alert-success"><?= h($success) ?></div>
        <?php endif; ?>


        <!-- SEARCH BAR -->
        <form method="get">
            <div class="search-row">
                <input type="text" name="q" placeholder="Input student name here..." value="<?= h($search) ?>">
                <button type="submit" class="btn-search">Search</button>
                <a href="clinic-patient-records.php" class="btn-reset">Clear Filters</a>
            </div>

            <!-- FILTERS -->
            <div class="filter-row">

                <!-- SORT -->
                <select name="sort" class="btn-grey" style="width:88px;">
                    <option value="" hidden>Sort</option>
                    <option value="name_asc"  <?= $sort==='name_asc'?'selected':'' ?>>Name A–Z</option>
                    <option value="name_desc" <?= $sort==='name_desc'?'selected':'' ?>>Name Z–A</option>
                    <option value="id_asc"    <?= $sort==='id_asc'?'selected':'' ?>>Student ID ↑</option>
                    <option value="id_desc"   <?= $sort==='id_desc'?'selected':'' ?>>Student ID ↓</option>
                    <option value="visits_desc" <?= $sort==='visits_desc'?'selected':'' ?>>Most Visits</option>
                    <option value="visits_asc"  <?= $sort==='visits_asc'?'selected':'' ?>>Fewest Visits</option>
                    <option value="lastvisit_desc" <?= $sort==='lastvisit_desc'?'selected':'' ?>>Newest Visit</option>
                    <option value="lastvisit_asc"  <?= $sort==='lastvisit_asc'?'selected':'' ?>>Oldest Visit</option>
                </select>

                <!-- DEPARTMENT -->
                <select name="dept" class="btn-grey" style="width: 250px;">
                    <option value="" hidden>Department</option>
                    <?php foreach ($departments as $d): ?>
                        <option value="<?= h($d) ?>" <?= $filterDept===$d?'selected':'' ?>>
                            <?= h($d) ?>
                        </option>
                    <?php endforeach; ?>
                </select>

                <!-- PROGRAM -->
                <select name="program" class="btn-grey" id="programSelect" <?= $filterDept? '': 'disabled'?> style="width: 250px;">
                    <option value="" selected hidden>Program</option>

                    <?php
                    // preload mappings from department → program
                    $deptProgMap = [];
                    foreach ($pdo->query("SELECT DISTINCT department, program FROM users") as $row) {
                        $deptProgMap[$row['program']] = $row['department'];
                    }
                    ?>

                    <?php foreach ($programs as $p): ?>
                        <option
                            value="<?= h($p) ?>"
                            data-dept="<?= h($deptProgMap[$p] ?? '') ?>"
                            <?= $filterProg===$p?'selected':'' ?>
                        >
                            <?= h($p) ?>
                        </option>
                    <?php endforeach; ?>
                </select>


                <!-- YEAR LEVEL -->
                <select name="yearLevel" class="btn-grey" style="width: 127px;">
                    <option value="" hidden>Year Level</option>
                    <?php foreach ($years as $y): ?>
                        <option value="<?= h($y) ?>" <?= (string)$filterYear===(string)$y?'selected':'' ?>>
                            <?= h($y) ?>
                        </option>
                    <?php endforeach; ?>
                </select>

                <label class="small" style="margin-left:13.2%;">Consultation Date:</label>
                <input type="date" name="from" class="pill" value="<?= h($dateFrom) ?>" style="height:35px;">
                <label class="small">to</label>
                <input type="date" name="to" class="pill" value="<?= h($dateTo) ?>" style="height:35px;">

            </div>
        </form>


        <!-- PATIENT TABLE -->
        <div class="table-wrap">
            <table class="records">
                <thead>
                    <tr>
                        <th>Student ID</th>
                        <th>Student Name</th>
                        <th>Department</th>
                        <th>Program</th>
                        <th>Year Level</th>
                        <th>Last Visit</th>
                        <th>No. of Visits</th>
                    </tr>
                </thead>

                <tbody>
                <?php if (empty($items)): ?>
                    <tr><td colspan="7" style="text-align:center;padding:36px;">No results found.</td></tr>
                <?php else: ?>
                    <?php foreach ($items as $row): ?>
                        <?php $rid = (int)$row['recordId']; ?>
                        <tr class="record-row"
                            data-id="<?= h($rid) ?>"
                            data-student="<?= h($row['student_id']) ?>"
                            data-name="<?= h($row['firstname'].' '.$row['lastname']) ?>"
                            data-dept="<?= h($row['department']) ?>"
                            data-program="<?= h($row['program']) ?>"
                            data-year="<?= h($row['year_level']) ?>"
                            data-last="<?= h($row['last_visit']) ?>"
                            data-visits="<?= h($row['visits_count']) ?>"
                        >
                            <td><?= h($row['student_id']) ?></td>
                            <td><?= h($row['firstname'].' '.$row['lastname']) ?></td>
                            <td><?= h($row['department']) ?></td>
                            <td><?= h($row['program']) ?></td>
                            <td><?= h($row['year_level']) ?></td>
                            <td><?= $row['last_visit'] ? date("M d, Y", strtotime($row['last_visit'])) : '—' ?></td>
                            <td><?= (int)$row['visits_count'] ?></td>
                        </tr>
                    <?php endforeach; ?>
                <?php endif; ?>
                </tbody>
            </table>

        <!-- PAGINATION -->
        <div class="pagination">
            <?php if ($page > 1): ?>
                <a href="?<?= http_build_query(array_merge($_GET, ['page'=>$page-1])) ?>" class="btn btn-light">Prev</a>
            <?php endif; ?>

            <span style="padding:6px 10px; background:#fff; border:1px solid #ddd; border-radius:6px;">
                Page <?= $page ?>
            </span>

            <?php if ($page < $totalPages): ?>
                <a href="?<?= http_build_query(array_merge($_GET, ['page'=>$page+1])) ?>" class="btn btn-light">Next</a>
            <?php endif; ?>
        </div>

    </div>
</div>
</div>

<!--                 PATIENT MODAL             -->
<div class="modal fade" id="patientRecordModal" tabindex="-1">
  <div class="modal-dialog modal-xl modal-dialog-scrollable">
    <div class="modal-content" style="border-radius:10px;">

      <div class="modal-header">
        <h4 class="modal-title">Patient Full Record</h4>
      </div>

      <div class="modal-body">

        <!-- Patient Info -->
        <div class="card p-3 mb-3">
            <h5 class="info-header">STUDENT INFORMATION</h5>
            <div class="row g-3">

                <div class="col-md-4">
                    <label class="fw-bold">Student ID</label>
                    <input type="text" id="view_studentId" class="form-control" readonly>
                </div>

                <div class="col-md-4">
                    <label class="fw-bold">Name</label>
                    <input type="text" id="view_studentName" class="form-control" readonly>
                </div>

                <div class="col-md-4">
                    <label class="fw-bold">Department</label>
                    <input type="text" id="view_department" class="form-control" readonly>
                </div>

                <div class="col-md-4">
                    <label class="fw-bold">Program</label>
                    <input type="text" id="view_program" class="form-control" readonly>
                </div>

                <div class="col-md-4">
                    <label class="fw-bold">Year Level</label>
                    <input type="text" id="view_yearLevel" class="form-control" readonly>
                </div>

                <div class="col-md-4">
                    <label class="fw-bold">Last Visit</label>
                    <input type="text" id="view_lastVisit" class="form-control" readonly>
                </div>

            </div>
        </div>

        <!-- Emergency Contact -->
        <div class="card p-3 mb-3" style="background: #FFF2F2; border: 1px solid #703434;">
            <h5 class="info-header" style="font-size: 20px; color: #8B0303; margin-bottom: 10px;">EMERGENCY CONTACT</h5>
                    <div class="row g-3" style="width:100%;">
                        <div class="col-md-6">
                            <label class="fw-bold">Contact Name</label>
                            <input type="text" id="view_emergencyName" class="form-control" readonly>
                        </div>
                        <div class="col-md-6">
                            <label class="fw-bold">Contact Number</label>
                            <input type="text" id="view_emergencyNumber" class="form-control" readonly>
                        </div>
                    </div>
            </div>
        <!-- Allergy Information -->
        <div class="card p-3 mb-3" style="background: #FFF2F2; border: 1px solid #703434;">
            <h5 class="info-header" style="font-size: 20px; color: #8B0303; margin-bottom: 10px;">ALERTS & IMPORTANT NOTES</h5>
                <div class="col-md-6">
                    <label class="fw-bold">Allergies:</label>
                        <div id="allergyContent"><em>—</em></div>
                </div> <br>
                <div class="col-md-6">
                    <label class="fw-bold">Conditions:</label>
                     <div id="conditionsContent"><em>—</em></div>
                </div> <br>
                <div class="col-md-6">
                    <label class="fw-bold">Current Medications:</label>
                        <div id="medicationsContent"><em>—</em></div>
                </div>
        </div>

        <!-- Latest Visits -->
        <div class="card p-3 mb-3">
            <h5 class="info-header">LATEST VISITS</h5>
            <div id="visitsContent"><em>—</em></div>
        </div>

        <!-- Dental Records -->
        <div class="card p-3 mb-3">
            <h5 class="info-header">DENTAL RECORDS</h5>
            <div id="dentalRecordContent"><em>—</em></div>
        </div>

        <!-- Medical Certificates -->
        <div class="card p-3 mb-3">
            <h5 class="info-header">MEDICAL CERTIFICATES</h5>
            <div id="medCertContent"><em>—</em></div>
        </div>

      </div>
        <div class="modal-footer" style="align-items: center;">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
        </div>
    </div>
  </div>
</div>


<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
// Preloaded details from server (safe JSON)
window.PATIENT_DETAILS = <?= $details_json ?>;
</script>

<script>
document.addEventListener("DOMContentLoaded", () => {

    const deptSelect = document.querySelector("select[name='dept']");
    const programSelect = document.getElementById("programSelect");
    const programOptions = programSelect ? programSelect.querySelectorAll("option[data-dept]") : [];

    function updateProgramDropdown() {
        const selectedDept = deptSelect ? deptSelect.value : '';
        if (!programSelect) return;

        if (!selectedDept) {
            programSelect.value = "";
            programSelect.disabled = true;
            programOptions.forEach(opt => opt.hidden = false);
            return;
        }

        programSelect.disabled = false;

        programOptions.forEach(opt => {
            if (opt.dataset.dept === selectedDept) opt.hidden = false;
            else opt.hidden = true;
        });

        const selectedProgram = programSelect.value;
        const selectedOption = programSelect.querySelector(`option[value="${selectedProgram}"]`);
        if (selectedProgram && selectedOption && selectedOption.hidden) {
            programSelect.value = "";
        }
    }

    if (deptSelect) {
        deptSelect.addEventListener("change", updateProgramDropdown);
        updateProgramDropdown();
    }

    // Modal logic: fill from preloaded window.PATIENT_DETAILS
    const modalEl = document.getElementById('patientRecordModal');
    const modal = new bootstrap.Modal(modalEl);

    function emptyNode(id, fallback = '<em>—</em>') {
        const el = document.getElementById(id);
        if (el) el.innerHTML = fallback;
    }

    document.querySelectorAll(".record-row").forEach(row => {
        row.addEventListener("click", function() {
            const recordId = this.dataset.id;
            if (!recordId) return;

            const details = window.PATIENT_DETAILS[recordId] || null;

            document.getElementById("view_studentId").value = this.dataset.student || '';
            document.getElementById("view_studentName").value = this.dataset.name || '';
            document.getElementById("view_department").value = this.dataset.dept || '';
            document.getElementById("view_program").value = this.dataset.program || '';
            document.getElementById("view_yearLevel").value = this.dataset.year || '';
            document.getElementById("view_lastVisit").value = this.dataset.last || '—';

            // Emergency contact and allergy data (from preloaded details)
            if (details) {
                const allergy = details.allergy || null;
                document.getElementById("view_emergencyName").value = allergy && allergy.emergency_contact_name ? allergy.emergency_contact_name : '';
                document.getElementById("view_emergencyNumber").value = allergy && allergy.emergency_contact_number ? allergy.emergency_contact_number : '';

                // Allergies, conditions, medications
                document.getElementById("allergyContent").innerHTML = allergy && allergy.allergens ? '<div>' + escapeHtml(allergy.allergens).replace(/\n/g,'<br>') + '</div>' : '<em>None recorded.</em>';
                document.getElementById("conditionsContent").innerHTML = allergy && allergy.conditions ? '<div>' + escapeHtml(allergy.conditions).replace(/\n/g,'<br>') + '</div>' : '<em>None recorded.</em>';
                document.getElementById("medicationsContent").innerHTML = allergy && allergy.current_medications ? '<div>' + escapeHtml(allergy.current_medications).replace(/\n/g,'<br>') + '</div>' : '<em>None recorded.</em>';

                // Dental records
                const dental = details.dental || [];
                if (dental.length) {
                    let html = '<table class="small-table"><thead><tr><th>Date</th><th>Service</th><th>Notes</th></tr></thead><tbody>';
                    dental.forEach(d => {
                        html += '<tr><td>' + (d.date ? escapeHtml(d.date) : '') + '</td><td>' + escapeHtml(d.service || '') + '</td><td>' + escapeHtml(d.notes || '') + '</td></tr>';
                    });
                    html += '</tbody></table>';
                    document.getElementById("dentalRecordContent").innerHTML = html;
                } else {
                    document.getElementById("dentalRecordContent").innerHTML = '<em>No dental records.</em>';
                }

                // Medical certificates
                const certs = details.certificates || [];
                if (certs.length) {
                    let html = '<table class="small-table"><thead><tr><th>Date Issued</th><th>Reason</th></tr></thead><tbody>';
                    certs.forEach(c => {
                        html += '<tr><td>' + (c.dateIssued ? escapeHtml(c.dateIssued) : '') + '</td><td>' + escapeHtml(c.reason || '') + '</td></tr>';
                    });
                    html += '</tbody></table>';
                    document.getElementById("medCertContent").innerHTML = html;
                } else {
                    document.getElementById("medCertContent").innerHTML = '<em>No medical certificates.</em>';
                }

                // Consultations + assessments + prescriptions
                const consultations = details.consultations || [];
                if (consultations.length) {
                    let html = '<table class="small-table"><thead><tr><th>Date</th><th>Doctor</th><th>Reason</th><th>Assessments / Prescriptions</th></tr></thead><tbody>';
                    consultations.forEach(c => {
                        let ap = '';
                        if (c.assessments && c.assessments.length) {
                            ap += '<strong>Assessments:</strong><ul>';
                            c.assessments.forEach(a => {
                                ap += '<li>' + (a.reason_for_visit ? escapeHtml(a.reason_for_visit) : '') + (a.diagnosis ? ' — ' + escapeHtml(a.diagnosis) : '') + '</li>';
                            });
                            ap += '</ul>';
                        }
                        if (c.prescriptions && c.prescriptions.length) {
                            ap += '<strong>Prescriptions:</strong><ul>';
                            c.prescriptions.forEach(p => {
                                ap += '<li>' + escapeHtml(p.medication_name || '') + (p.dosage ? ' — ' + escapeHtml(p.dosage) : '') + (p.duration ? ' (' + escapeHtml(p.duration) + ')' : '') + '</li>';
                            });
                            ap += '</ul>';
                        }
                        html += '<tr><td>' + (c.date ? escapeHtml(c.date) : '') + '</td><td>' + escapeHtml(c.doctorId || '') + '</td><td>' + escapeHtml(c.reason || '') + '</td><td>' + ap + '</td></tr>';
                    });
                    html += '</tbody></table>';
                    document.getElementById("visitsContent").innerHTML = html;
                } else {
                    document.getElementById("visitsContent").innerHTML = '<em>No consultations recorded.</em>';
                }

            } else {
                // No details found for this recordId
                document.getElementById("view_emergencyName").value = '';
                document.getElementById("view_emergencyNumber").value = '';
                document.getElementById("allergyContent").innerHTML = '<em>None recorded.</em>';
                document.getElementById("conditionsContent").innerHTML = '<em>None recorded.</em>';
                document.getElementById("medicationsContent").innerHTML = '<em>None recorded.</em>';
                document.getElementById("dentalRecordContent").innerHTML = '<em>No dental records.</em>';
                document.getElementById("medCertContent").innerHTML = '<em>No medical certificates.</em>';
                document.getElementById("visitsContent").innerHTML = '<em>No consultations recorded.</em>';
            }

            modal.show();
        });
    });

    function escapeHtml(str) {
        if (str === null || str === undefined) return '';
        return String(str)
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#39;");
    }

});
</script>
</body>
</html>
