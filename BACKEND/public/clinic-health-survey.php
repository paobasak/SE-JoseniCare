<?php
// clinic-health-survey.php
require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../config/database.php';

$scriptPath = dirname($_SERVER['SCRIPT_NAME']);
$basePath = str_replace('/public', '', $scriptPath);
if ($basePath === '/' || $basePath === '') $basePath = '';

$pdo = getDbConnection();

// flash
$flash = getFlashMessage();
$error = '';
$success = '';
if (is_array($flash)) {
    if (($flash['type'] ?? '') === 'error') $error = $flash['message'] ?? '';
    if (($flash['type'] ?? '') === 'success') $success = $flash['message'] ?? '';
}

// filters & controls (no search bar: anonymized)
$range    = $_GET['range'] ?? 'today'; // today, past5, past30, custom
$dateFrom = $_GET['from'] ?? '';
$dateTo   = $_GET['to'] ?? '';
$dept     = $_GET['dept'] ?? '';
$program  = $_GET['program'] ?? '';
$year     = $_GET['year'] ?? '';
$groupBy  = $_GET['groupBy'] ?? 'department'; // department|program|year_level

$perPage = 15;
$page = max(1, (int)($_GET['page'] ?? 1));
$offset = ($page - 1) * $perPage;

// presets for date ranges
$today = new DateTimeImmutable('today');
if ($range === 'today') {
    $dateFrom = $today->format('Y-m-d');
    $dateTo   = $today->format('Y-m-d');
} elseif ($range === 'past5') {
    $dateFrom = $today->sub(new DateInterval('P5D'))->format('Y-m-d');
    $dateTo   = $today->format('Y-m-d');
} elseif ($range === 'past30') {
    $dateFrom = $today->sub(new DateInterval('P30D'))->format('Y-m-d');
    $dateTo   = $today->format('Y-m-d');
}
// if 'custom' then rely on user-supplied from/to

// Build WHERE parts and params (applies to queries below)
$whereParts = [];
$params = [];

if ($dateFrom !== '') {
    $whereParts[] = "hs.symptom_start_date >= :dateFrom";
    $params[':dateFrom'] = $dateFrom;
}
if ($dateTo !== '') {
    $whereParts[] = "hs.symptom_start_date <= :dateTo";
    $params[':dateTo'] = $dateTo;
}
if ($dept !== '') {
    $whereParts[] = "u.department = :dept";
    $params[':dept'] = $dept;
}
if ($program !== '') {
    $whereParts[] = "u.program = :program";
    $params[':program'] = $program;
}
if ($year !== '') {
    $whereParts[] = "u.year_level = :yearLevel";
    $params[':yearLevel'] = $year;
}

// no search input — data is anonymized

$whereSql = count($whereParts) ? 'WHERE ' . implode(' AND ', $whereParts) : '';

// 1) Totals (total check-ins, feeling well counts, reported symptom counts)
// Note: feeling_well_count counts healthRating IN (1,2,3) as "feeling well"
$sqlTotals = "
SELECT
    COUNT(*) AS total_checks,
    SUM(CASE WHEN hs.healthRating IN (1,2,3) THEN 1 ELSE 0 END) AS feeling_well_count,
    SUM(CASE WHEN TRIM(COALESCE(hs.symptoms, '')) <> '' THEN 1 ELSE 0 END) AS reported_symptoms_count
FROM healthSurvey hs
JOIN users u ON u.id = hs.user_id
" . $whereSql . "
";
$stmtTotals = $pdo->prepare($sqlTotals);
foreach ($params as $k => $v) $stmtTotals->bindValue($k, $v);
$stmtTotals->execute();
$totals = $stmtTotals->fetch(PDO::FETCH_ASSOC) ?: ['total_checks'=>0,'feeling_well_count'=>0,'reported_symptoms_count'=>0];

// 2) Rows for "Latest Responses" (paginated)
// NOTE: anonymized — do not show student names or IDs.
$sqlRows = "
SELECT hs.symptom_start_date, hs.symptoms, hs.healthRating, u.department, u.program, u.year_level
FROM healthSurvey hs
JOIN users u ON u.id = hs.user_id
" . $whereSql . "
ORDER BY hs.symptom_start_date DESC
LIMIT :limit OFFSET :offset
";
$stmtRows = $pdo->prepare($sqlRows);
foreach ($params as $k => $v) $stmtRows->bindValue($k, $v);
$stmtRows->bindValue(':limit', (int)$perPage, PDO::PARAM_INT);
$stmtRows->bindValue(':offset', (int)$offset, PDO::PARAM_INT);
$stmtRows->execute();
$rows = $stmtRows->fetchAll(PDO::FETCH_ASSOC);

// 3) totalRows for pagination (count)
$sqlCount = "
SELECT COUNT(*) FROM healthSurvey hs
JOIN users u ON u.id = hs.user_id
" . $whereSql . "
";
$stmtCount = $pdo->prepare($sqlCount);
foreach ($params as $k => $v) $stmtCount->bindValue($k, $v);
$stmtCount->execute();
$totalRows = (int)$stmtCount->fetchColumn();
$totalPages = (int)ceil(max(1, $totalRows) / $perPage);

// 4) Symptom prevalence: fetch symptom column for all matching rows (no limit)
// Prevalence percentages are calculated against total_checkins (as requested)
$sqlSymptoms = "
SELECT hs.symptoms
FROM healthSurvey hs
JOIN users u ON u.id = hs.user_id
" . $whereSql . "
";
$stmtSymptoms = $pdo->prepare($sqlSymptoms);
foreach ($params as $k => $v) $stmtSymptoms->bindValue($k, $v);
$stmtSymptoms->execute();
$symptomRows = $stmtSymptoms->fetchAll(PDO::FETCH_COLUMN);

// parse symptom text into tokens and count unique per row (prevalence)
$symptomCounts = [];
$totalSymptomReports = 0;
foreach ($symptomRows as $sText) {
    if (!is_string($sText) || trim($sText) === '') continue;
    $parts = preg_split('/[,\n;]+/', $sText);
    $seenInRow = [];
    foreach ($parts as $part) {
        $p = trim(mb_strtolower($part));
        if ($p === '') continue;
        $p = preg_replace('/\s+/', ' ', $p);
        if (isset($seenInRow[$p])) continue;
        $seenInRow[$p] = true;
        $symptomCounts[$p] = ($symptomCounts[$p] ?? 0) + 1;
        $totalSymptomReports++;
    }
}
arsort($symptomCounts);

// 5) Trend insights (group by selected dimension).
// We only count rows where symptoms are reported for trend insights.
$trendWhereParts = $whereParts; // copy base filters (date/filters)
$trendWhereParts[] = "TRIM(COALESCE(hs.symptoms, '')) <> ''"; // trend only considers symptom-reporting rows
$trendWhereSql = 'WHERE ' . implode(' AND ', $trendWhereParts);

// Choose group column
$groupColumn = 'u.department';
$groupLabel = 'department';
if ($groupBy === 'program') { $groupColumn = 'u.program'; $groupLabel = 'program'; }
elseif ($groupBy === 'year_level') { $groupColumn = 'u.year_level'; $groupLabel = 'year_level'; }

// build trend SQL (prepared)
$sqlTrend = "
SELECT " . $groupColumn . " AS label, COUNT(*) AS cnt
FROM healthSurvey hs
JOIN users u ON u.id = hs.user_id
" . $trendWhereSql . "
GROUP BY " . $groupColumn . "
ORDER BY cnt DESC
LIMIT 12
";
$stmtTrend = $pdo->prepare($sqlTrend);
foreach ($params as $k => $v) {
    // trend uses same params plus the symptoms-check we added; those spectral params are already applied.
    $stmtTrend->bindValue($k, $v);
}
$stmtTrend->execute();
$trendData = $stmtTrend->fetchAll(PDO::FETCH_ASSOC);

// 6) Weather (use file_get_contents with a timeout; no cURL at all)
$weather = [
    'temp_c' => null,
    'condition' => null,
    'humidity' => null,
    'feelslike_c' => null,
    'uv' => null,
    'raw' => null,
];
$weather_api_key = 'abb99554fc5c4b52a4210809250111';
$city = 'Cebu City, Philippines';
$weather_url = "http://api.weatherapi.com/v1/current.json?key=" . urlencode($weather_api_key) . "&q=" . urlencode($city) . "&aqi=no";

$ctx = stream_context_create([
    'http' => [
        'timeout' => 5,
        'method' => 'GET',
        'header' => "User-Agent: JoseniCare/1.0\r\n"
    ]
]);
$resp = @file_get_contents($weather_url, false, $ctx);
if ($resp !== false) {
    $j = json_decode($resp, true);
    if (is_array($j) && isset($j['current'])) {
        $weather['temp_c'] = $j['current']['temp_c'] ?? null;
        $weather['condition'] = $j['current']['condition']['text'] ?? null;
        $weather['humidity'] = $j['current']['humidity'] ?? null;
        $weather['feelslike_c'] = $j['current']['feelslike_c'] ?? null;
        $weather['uv'] = $j['current']['uv'] ?? null;
        $weather['raw'] = $j;
    }
}

// 7) Advisory & dynamic supply advisory (based on top symptoms + weather)
$topSymptoms = array_slice(array_keys($symptomCounts), 0, 4);
$advisory = [];
if (!empty($topSymptoms)) {
    $advisory[] = "Top reported issues: " . implode(', ', array_map('ucwords', $topSymptoms)) . ".";
}
if ($weather['temp_c'] !== null) {
    if ($weather['temp_c'] >= 32) $advisory[] = "High temperatures may cause mild dehydration, headaches, and dizziness.";
    if ($weather['humidity'] !== null && $weather['humidity'] >= 75) $advisory[] = "High humidity may worsen coughs, colds, and sore throat irritation.";
    if ($weather['uv'] !== null && $weather['uv'] >= 8) $advisory[] = "UV index is high — recommend sun protection for outdoor activities.";
}

// Dynamic supply suggestions (basic rules)
$supply = [];
// If temperature high or dehydration symptoms (e.g., "headache","fatigue","nausea") suggest ORS, water
if (($weather['temp_c'] !== null && $weather['temp_c'] >= 30) ||
    count(array_intersect($topSymptoms, ['headache','fatigue','nausea','dizziness'])) > 0) {
    $supply[] = "Oral Rehydration Salts (ORS) / Water supply";
}
// If cough, sore throat, congestion -> cough medicines, lozenges, masks
if (count(array_intersect($topSymptoms, ['cough','sore throat','nasal congestion'])) > 0) {
    $supply[] = "Cough & cold medication (OTC) and throat lozenges";
    $supply[] = "Surgical masks for symptomatic students";
}
// If high humidity and respiratory symptoms -> cold compress / tissue
if ($weather['humidity'] !== null && $weather['humidity'] >= 75) {
    $supply[] = "Cooling packs / cold compress";
    $supply[] = "Tissue packs for runny nose";
}
// Paracetamol if fever/fatigue
if (in_array('fever', $topSymptoms) || in_array('fatigue', $topSymptoms) || in_array('headache', $topSymptoms)) {
    $supply[] = "Paracetamol (acetaminophen) — short supply for symptomatic students";
}
// ensure unique and sensible order
$supply = array_values(array_unique($supply));
if (empty($supply)) {
    // fallback default list similar to screenshot
    $supply = [
        "Oral Rehydration Salts (ORS)",
        "Cooling packs / Cold compress",
        "Cough & cold medication",
        "Throat lozenges",
        "Surgical masks",
        "Tissue packs",
        "Paracetamol (acetaminophen)"
    ];
}

// 8) filter inputs sources
$departments = $pdo->query("SELECT DISTINCT department FROM users ORDER BY department ASC")->fetchAll(PDO::FETCH_COLUMN);
$programs = $pdo->query("
    SELECT DISTINCT program, department
    FROM users
    WHERE program IS NOT NULL AND department IS NOT NULL
    ORDER BY program ASC
")->fetchAll(PDO::FETCH_ASSOC);
$years = $pdo->query("SELECT DISTINCT year_level FROM users ORDER BY year_level ASC")->fetchAll(PDO::FETCH_COLUMN);

// helpers
function h($v){ return htmlspecialchars($v ?? '', ENT_QUOTES, 'UTF-8'); }

$survey_json_data = [
    'rows' => $rows,
    'symptoms' => $symptomCounts,
    'trend' => $trendData,
];
$survey_json = json_encode($survey_json_data, JSON_HEX_TAG|JSON_HEX_APOS|JSON_HEX_QUOT|JSON_HEX_AMP);
if ($survey_json === false) $survey_json = '{}';

?>
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8" />
<title>JoseniCare | Clinic Health Survey</title>
<meta name="viewport" content="width=device-width, initial-scale=1" />
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" />

<link rel="preload" href="<?php echo $basePath; ?>/dist/css/adminlte.css" as="style" />
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fontsource/source-sans-3@5.0.12/index.css" media="print" onload="this.media='all'">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/overlayscrollbars@2.11.0/styles/overlayscrollbars.min.css" />
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css" />
<link rel="stylesheet" href="<?php echo $basePath; ?>/dist/css/adminlte.css" />

<style>
/* simplified styles tuned to screenshot layout */
body { background:#f5f6f8;}
.page { display:flex; min-height:100vh; }
/* SIDEBAR */
.sidebar { width:4%; background:#171821; padding:10px; display:flex; flex-direction:column; align-items:center; }
.sidebar-logo img { width:58px; height:58px; padding:5px; border-radius:14px; margin-bottom:28px; }
.sidebar-nav { display:flex; flex-direction:column; gap:50px; align-items:center; }
.nav-item { width:40px; height:40px; background:#262b27; border-radius:14px; display:flex; justify-content:center; align-items:center; color:#9cad9f; font-size:22px; border:2px solid transparent; }
.nav-item.active { border-color:#3fe17b; color:#3fe17b; background:#2b312e; }

/* MAIN */
.main-content { flex:1; padding:28px; }
.title { font-size:80px; font-weight:800; color:#123c24; }
.small-muted { color:#6b6b6b; font-size:13px; margin-bottom:18px; }
.controls { display:flex; gap:10px; align-items:center; margin-bottom:12px; flex-wrap:wrap; }
.card-small { 
    background: #ffffff;
    padding: 20px 28px;
    border-radius: 16px;
    width: 341.3px;
    height: 118px;
    box-shadow: 0 4px 14px rgba(0,0,0,0.08);
    display: flex;
    align-items: center;
    gap: 18px;
    /* padding:18px; border-radius:12px; background:#fff; box-shadow:0 6px 18px rgba(0,0,0,0.06); min-width:160px;  */
}
.stat-icon {
    background: #e0ffd7;
    width: 80px;
    height: 80px;
    border-radius: 14px;
}
.stat-label {
    font-size: 13px;
    color: #000000;
}
.stat-num { 
    font-size:43px; 
    font-weight:700; 
    color:#214b33; 
}
.insights {
    margin: 10px;
}
.cards-row { display:flex; gap:12px; margin-bottom:18px; flex-wrap:wrap; }
.table-wrap { background:#fff; padding:20px; box-shadow: 0px 0px 6px 2px rgba(0, 0, 0, 0.25); border-radius: 15px; margin-bottom: 20px; }
.small-table th, .small-table td { padding:6px; border-bottom:1px solid #eee; font-size:13px; }
.progress-custom { height:16px; border-radius:10px; background:#e9f7ee; overflow:hidden; }
.progress-bar-custom { height:100%; display:block; border-radius:10px; background:linear-gradient(90deg,#2ecc71,#27ae60); }
.right-column .table-wrap { margin-bottom:16px; }
.footer { text-align:center; color:#777; font-size:13px; margin-top:18px; }
.header-subtitle {
    color: #34703A;
    font-size: 29px;
    font-weight: 400;
    margin-bottom: 25px;
}

.form-select {
    border: px #9E9E9E solid;
}

.weather-card {
    background: #6fa3e8;
    height: 175px;
    color: #fff;
    border-radius: 18px;
    padding: 18px 22px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    box-shadow: 0 6px 18px rgba(0,0,0,0.15);
    margin-bottom: 15px;
}

.weather-location {
    font-weight: 500;
    margin-bottom: 10px;
    color: #FFFFFF;
    font-size: 35px;
}

.weather-main {
    display: flex;
    align-items: center;
    gap: 14px;
}

.weather-icon img {
    width: 64px;
    height: 64px;
}

.weather-temp {
    font-size: 56px;
    font-weight: 700;
    line-height: 1;
}

.weather-right {
    font-size: 16px;
    line-height: 1.8;
    text-align: left;
}

.trend-info {
    margin-bottom: 30px;
    font-weight: 700;
}

</style>
</head>
<body>
<div class="page">
    <aside class="sidebar">
        <div class="sidebar-logo"><img src="../dist/assets/img/josecare-logo.png" alt="logo"></div>
        <nav class="sidebar-nav">
            <a href="clinic-dashboard.php" class="nav-item"><i class="bi bi-grid-fill"></i></a>
            <a href="clinic-appointments.php" class="nav-item"><i class="bi bi-calendar2-check"></i></a>
            <a href="clinic-patient-records.php" class="nav-item"><i class="bi bi-folder2-open"></i></a>
            <a href="clinic-health-survey.php" class="nav-item active"><i class="bi bi-clipboard-pulse"></i></a>
            <a href="clinic-inventory.php" class="nav-item"><i class="bi bi-box-seam"></i></a>
            <a href="clinic-settings.php" class="nav-item"><i class="bi bi-gear"></i></a>
        </nav>
    </aside>

    <div class="main-content container-fluid">
        <div class="d-flex justify-content-between align-items-center">
            <div>
                <div class="title">HEALTH SURVEY</div>
                <div class="header-subtitle">Daily Check-In Summary</div>
            </div>
        </div>

        <?php if ($error): ?><div class="alert alert-danger"><?= h($error) ?></div><?php endif; ?>
        <?php if ($success): ?><div class="alert alert-success"><?= h($success) ?></div><?php endif; ?>

        <!-- Controls (anonymized; no search field) -->
        <form method="get" class="mb-3">
            <div class="controls">
                <select name="dept" id="deptSelect" class="form-select" style="width:200px;">
                    <option value="">All Departments</option>
                    <?php foreach ($departments as $d): ?>
                        <option value="<?= h($d) ?>" <?= $d===$dept?'selected':'' ?>><?= h($d) ?></option>
                    <?php endforeach; ?>
                </select>

                <select name="program"
                        id="programSelect"
                        class="form-select"
                        style="width:200px;"
                        <?= $dept ? '' : 'disabled' ?>>

                    <option value="">All Programs</option>

                    <?php foreach ($programs as $p): ?>
                        <option value="<?= h($p['program']) ?>"
                                data-dept="<?= h($p['department']) ?>"
                                <?= $p['program'] === $program ? 'selected' : '' ?>>
                            <?= h($p['program']) ?>
                        </option>
                    <?php endforeach; ?>
                </select>


                <select name="year" class="form-select" style="width:120px;">
                    <option value="">All Years</option>
                    <?php foreach ($years as $y): ?>
                        <option value="<?= h($y) ?>" <?= (string)$y===(string)$year?'selected':'' ?>><?= h($y) ?></option>
                    <?php endforeach; ?>
                </select>

                <select name="groupBy" class="form-select" style="width:180px;">
                    <option value="department" <?= $groupBy==='department'?'selected':'' ?>>Group: Department</option>
                    <option value="program" <?= $groupBy==='program'?'selected':'' ?>>Group: Program</option>
                    <option value="year_level" <?= $groupBy==='year_level'?'selected':'' ?>>Group: Year Level</option>
                </select>

                <button type="submit" class="btn btn-success">Apply</button>
                <a href="clinic-health-survey.php" class="btn btn-outline-secondary">Reset</a>
            </div>
        </form>

        <!-- Cards -->
        <div class="cards-row mb-3">
            <div class="card-small">
                <div class="stat-icon"></div>
                <div>
                    <div class="stat-label">Total Check-Ins</div>
                    <div class="stat-num"><?= (int)$totals['total_checks'] ?></div>
                </div>
            </div>
            <div class="card-small">
                <div class="stat-icon"></div>
                <div>
                    <div class="stat-label">Students Feeling Well</div>
                    <div class="stat-num"><?= (int)$totals['feeling_well_count'] ?></div>
                </div>
            </div>
            <div class="card-small">
                <div class="stat-icon"></div>
                <div>
                    <div class="stat-label">Reported Symptoms</div>
                    <div class="stat-num"><?= (int)$totals['reported_symptoms_count'] ?></div>
                </div>
            </div>
            <div class="card-small">
                <div class="stat-icon"></div>
                <div>
                    <div class="stat-label">Symptoms Compared Yesterday</div>
                    <div class="stat-num">
                        <?= $totals['total_checks'] > 0 ? '+' . round((($totals['reported_symptoms_count']/$totals['total_checks'])*100),1) . '%' : '—' ?>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-3">
            <div class="col-lg-7">
                <div class="table-wrap">
                        <div>
                            <h5 style="display: inline-block; font-weight: 700; margin-left: 9px;">Showing results for:</h5>
                            <select name="range" class="form-select" onchange="this.form.submit()" style="width:270px; display: inline-block; margin-left: 38%; margin-top: 10px; margin-bottom:12px;">
                                <option value="today" <?= $range==='today'?'selected':'' ?>>Today</option>
                                <option value="past5" <?= $range==='past5'?'selected':'' ?>>Past 5 Days</option>
                                <option value="past30" <?= $range==='past30'?'selected':'' ?>>Past 30 Days</option>
                                <option value="custom" <?= $range==='custom'?'selected':'' ?>>Custom</option>
                            </select>
                        </div>
                        <div class="table-wrap insights" style="background: #FFF6F6; box-shadow: 0px 0px 6px 2px rgba(0, 0, 0, 0.25); border-radius: 15px;">
                            <h5 class="trend-info">Symptom Prevalence</h5>
                            <?php if (empty($symptomCounts)): ?>
                                <p><em>No symptoms reported for the selected filters.</em></p>
                            <?php else: ?>
                                <table class="w-100">
                                    <thead>
                                        <tr><th style="text-align:left">    </th><th>Cases</th><th style="text-align:right">%</th></tr>
                                    </thead>
                                    <tbody>
                                        <?php foreach ($symptomCounts as $sym => $cnt):
                                            $pct = $totals['total_checks'] ? round(($cnt / (int)$totals['total_checks']) * 100, 1) : 0;
                                        ?>
                                        <tr>
                                            <td style="padding:8px 6px;"><?= h(ucwords($sym)) ?></td>
                                            <td style="padding:8px 6px;"><?= (int)$cnt ?></td>
                                            <td style="padding:8px 6px;text-align:right;"><?= h($pct) ?>%</td>
                                        </tr>
                                        <?php endforeach; ?>
                                    </tbody>
                                </table>
                            <?php endif; ?>
                        </div>

                        <div class="table-wrap insights">
                        <h5 class="trend-info" style="margin-bottom: 7px;">Trend Insights</h5>
                        <p> Distribution of symptoms by <?= h(ucfirst($groupLabel)) ?></p><br>
                        <?php if (empty($trendData)): ?>
                            <p><em>No trend data.</em></p>
                        <?php else: ?>
                            <ul class="list-unstyled">
                                <?php foreach ($trendData as $t): 
                                    $label = $t['label'] ?: '—';
                                    $cnt = (int)$t['cnt'];
                                    // compute simple percent vs total symptom-reporting rows (for display)
                                    $trendTotal = array_sum(array_column($trendData, 'cnt')) ?: 1;
                                    $pct = round(($cnt / $trendTotal) * 100, 1);
                                ?>
                                    <li style="padding:8px 0;border-bottom:1px solid #f0f0f0; display:flex; justify-content:space-between; align-items:center;">
                                        <div style="width:70%"><?= h($label) ?></div>
                                        <div style="width:30%; text-align:right; font-weight:700;"><?= h($pct) ?>%</div>
                                    </li>
                                <?php endforeach; ?>
                            </ul>
                        <?php endif; ?>
                        </div>

                        <div class="table-wrap insights" style="background: #FFF6F6; box-shadow: 0px 0px 6px 2px rgba(0, 0, 0, 0.25); border-radius: 15px;">
                            <h5 class="trend-info">Latest Responses</h5>
                            <table class="table table-sm" style="text-align: center;">
                                <thead>
                                    <tr><th>Date</th><th>Department</th><th>Symptoms</th><th>Rating</th></tr>
                                </thead>
                                <tbody>
                                    <?php if (empty($rows)): ?>
                                        <tr><td colspan="5" class="text-center py-4"><em>No records.</em></td></tr>
                                    <?php else: ?>
                                        <?php foreach ($rows as $r): ?>
                                            <tr>
                                                <td><?= h($r['symptom_start_date'] ?? '') ?></td>
                                                <td><?= h($r['department']) ?></td>
                                                <td style="text-align:left"><?= h($r['symptoms']) ?: '—' ?></td>
                                                <td><?= (int)$r['healthRating'] ?></td>
                                            </tr>
                                        <?php endforeach; ?>
                                    <?php endif; ?>
                                </tbody>
                            </table>

                            <div class="d-flex justify-content-between align-items-center">
                                <div>Page <?= $page ?> of <?= $totalPages ?></div>
                                <div>
                                    <?php if ($page>1): ?>
                                        <a class="btn btn-sm btn-outline-secondary" href="?<?= http_build_query(array_merge($_GET, ['page'=>$page-1])) ?>">Prev</a>
                                    <?php endif; ?>
                                    <?php if ($page < $totalPages): ?>
                                        <a class="btn btn-sm btn-outline-secondary" href="?<?= http_build_query(array_merge($_GET, ['page'=>$page+1])) ?>">Next</a>
                                    <?php endif; ?>
                                </div>
                            </div>
                        </div>
                </div>
            </div>

            <div class="col-lg-5 right-column">
                <div class="table-wrap">
                        <div class="weather-card">
                            <div class="weather-left">
                                <div class="weather-location"><?= h($city) ?></div>

                                <div class="weather-main">
                                    <div class="weather-icon">
                                        <?php
                                        $condition = strtolower($weather['condition'] ?? '');
                                        $iconUrl = '';
                                        if (strpos($condition, 'sunny') !== false || strpos($condition, 'clear') !== false) {
                                            $iconUrl = 'https://cdn-icons-png.flaticon.com/512/869/869869.png';
                                        } elseif (strpos($condition, 'cloud') !== false) {
                                            $iconUrl = 'https://cdn-icons-png.flaticon.com/512/414/414825.png';
                                        } elseif (strpos($condition, 'rain') !== false) {
                                            $iconUrl = 'https://cdn-icons-png.flaticon.com/512/414/414974.png';
                                        } else {
                                            $iconUrl = 'https://cdn-icons-png.flaticon.com/512/252/252035.png';
                                        }
                                        ?>
                                        <img src="<?= h($iconUrl) ?>" alt="Weather">
                                    </div>

                                    <div class="weather-temp">
                                        <?= $weather['temp_c'] !== null ? h($weather['temp_c']) . '°' : '—' ?>
                                    </div>
                                </div>
                            </div>

                            <div class="weather-right">
                                <div>Feels Like: <strong><?= h($weather['feelslike_c'] ?? '—') ?>°</strong></div>
                                <div>Humidity: <strong><?= h($weather['humidity'] ?? '—') ?>%</strong></div>
                                <div>
                                    UV Index:
                                    <strong>
                                        <?php
                                        if ($weather['uv'] === null) echo '—';
                                        elseif ($weather['uv'] >= 8) echo 'High';
                                        elseif ($weather['uv'] >= 4) echo 'Moderate';
                                        else echo 'Low';
                                        ?>
                                    </strong>
                                </div>
                            </div>
                        </div>


                    <div class="table-wrap">
                        <h5>Today's Health Advisory</h5>

                        <?php if (empty($advisory)): ?>
                            <p class="text-muted"><em>No specific advisory at the moment.</em></p>
                        <?php else: ?>
                            <table class="table table-sm mb-0">
                                <tbody>
                                    <?php foreach ($advisory as $i => $msg): ?>
                                        <tr>
                                            <td style="width:28px; font-weight:700;">
                                                <?= $i + 1 ?>.
                                            </td>
                                            <td>
                                                <?= h($msg) ?>
                                            </td>
                                        </tr>
                                    <?php endforeach; ?>
                                </tbody>
                            </table>
                        <?php endif; ?>
                    </div>


                    <div class="table-wrap">
                        <h5>Today's Supply Advisory</h5>
                        <ol style="padding-left:18px; margin:0;">
                            <?php foreach ($supply as $s): ?>
                                <li style="margin-bottom:8px;"><?= h($s) ?></li>
                            <?php endforeach; ?>
                        </ol>
                    </div>
                </div>
            </div>
        </div>

        <div class="footer">
            Last Updated: <?= date('F j, Y') ?> · <?= date('g:i A') ?>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
window.SURVEY_DATA = <?= $survey_json ?>;
</script>

<script>
document.addEventListener("DOMContentLoaded", () => {
    const deptSelect = document.getElementById("deptSelect");
    const programSelect = document.getElementById("programSelect");

    function filterPrograms() {
        const dept = deptSelect.value;
        let hasVisible = false;

        [...programSelect.options].forEach(opt => {
            if (!opt.value) return;

            if (!dept || opt.dataset.dept === dept) {
                opt.hidden = false;
                hasVisible = true;
            } else {
                opt.hidden = true;
                if (opt.selected) opt.selected = false;
            }
        });

        programSelect.disabled = !dept || !hasVisible;
    }

    deptSelect.addEventListener("change", filterPrograms);
    filterPrograms(); // run on page load
});
</script>

</body>
</html>
