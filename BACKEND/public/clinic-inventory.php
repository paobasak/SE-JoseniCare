<?php

require_once __DIR__ . '/../config/session.php';
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../config/database.php';

$scriptPath = dirname($_SERVER['SCRIPT_NAME']);
$basePath = str_replace('/public', '', $scriptPath);
if ($basePath === '/' || $basePath === '') $basePath = '';

$flash = getFlashMessage();

$error = '';
$success = '';

if (is_array($flash)) {
    if (($flash['type'] ?? '') === 'error') $error = $flash['message'] ?? '';
    if (($flash['type'] ?? '') === 'success') $success = $flash['message'] ?? '';
}

$sort = $_GET['sort'] ?? '';
$filter = $_GET['filter'] ?? '';
$search = trim($_GET['q'] ?? '');

$pdo = getDbConnection();

$sort   = $_GET['sort'] ?? '';
$filter = $_GET['filter'] ?? '';

$sql = "SELECT * FROM items";
$params = [];

// SEARCH
if ($search !== "") {
    $sql .= " WHERE (itemName LIKE :q)";
    $params[':q'] = "%$search%";
}

// FILTERS
switch ($filter) {
    case "low_stock":
        $sql .= ($search ? " AND" : " WHERE") . " quantity > 0 AND quantity <= 5";
        break;

    case "out_stock":
        $sql .= ($search ? " AND" : " WHERE") . " quantity = 0";
        break;

    case "exp_soon":
        $sql .= ($search ? " AND" : " WHERE") . " expirationDate BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 30 DAY)";
        break;

    case "expired":
        $sql .= ($search ? " AND" : " WHERE") . " expirationDate < NOW() AND expirationDate != '9999-12-31 00:00:00'";
        break;

    case "nonexp":
        $sql .= ($search ? " AND" : " WHERE") . " expirationDate = '9999-12-31 00:00:00'";
        break;
}

// SORTING
switch ($sort) {
    case "name_asc":
        $sql .= " ORDER BY itemName ASC";
        break;
    case "name_desc":
        $sql .= " ORDER BY itemName DESC";
        break;
    case "qty_asc":
        $sql .= " ORDER BY quantity ASC";
        break;
    case "qty_desc":
        $sql .= " ORDER BY quantity DESC";
        break;
    case "exp_asc":
        $sql .= " ORDER BY expirationDate ASC";
        break;
    case "exp_desc":
        $sql .= " ORDER BY expirationDate DESC";
        break;
    default:
        $sql .= " ORDER BY itemName ASC";
}

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$items = $stmt->fetchAll();

// 2. AUTO UPDATE STATUS BASED ON QUANTITY (Update DB only if status actually changes)
foreach ($items as $item) {
    $qty = (int)$item['quantity'];
    $newStatus = $item['status'];

    if ($qty === 0) {
        $newStatus = "Out of Stock";
    } elseif ($qty > 0 && $qty <= 5) {
        $newStatus = "Low Stock";
    } else {
        $newStatus = "In Stock";
    }

    if ($newStatus !== $item['status']) {
        $u = $pdo->prepare("UPDATE items SET status = :s WHERE itemId = :id");
        $u->execute([
            ':s' => $newStatus,
            ':id' => $item['itemId']
        ]);
        $itemsById[$item['itemId']]['status'] = $newStatus;
    }
}

// 3. RE-FETCH ITEMS WITH UPDATED STATUS (optional but safe)
$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$items = $stmt->fetchAll();


$itemsById = [];
foreach ($items as $it) {
    $itemsById[$it['itemId']] = $it;
}

// COMPUTE METRICS
$totalItemsInStock = count($items);
$lowStock = 0;
$outOfStock = 0;
$expiringSoon = 0;
$expiredCount = 0;

$todayTs = strtotime('today');
$soonTs  = strtotime('+30 days');

foreach ($items as $it) {
    $qty = (int)$it['quantity'];
    $alertClass = '';

    if ($qty === 0) {
        $outOfStock++;
    } 
    if ($qty > 0 && $qty <= 5) {
        $lowStock++;
    }

    // Determine expiry status for metrics only (no side effects)
    if (!empty($it['expirationDate']) && $it['expirationDate'] !== "9999-12-31 00:00:00") {
        $expTs = strtotime($it['expirationDate']);
        if ($expTs < $todayTs) {
            $expiredCount++;
        } elseif ($expTs <= $soonTs) {
            $expiringSoon++;
        }
    }
}


foreach ($items as $it) {

    $itemId = $it['itemId'];
    $qty    = (int)$it['quantity'];
    $unit   = $it['unit'] ?? '';
    $alertsToCreate = [];

    // Stock-based alerts
    if ($qty === 0) {
        $alertsToCreate[] = "Out of Stock";
    } elseif ($qty > 0 && $qty <= 5) {
        $alertsToCreate[] = "Low Stock";
    }

    // Expiry-based alerts
    if (!empty($it['expirationDate']) && $it['expirationDate'] !== "9999-12-31 00:00:00") {

        $expTs = strtotime($it['expirationDate']);

        // 1. Already expired
        if ($expTs < $todayTs) {
            $alertsToCreate[] = "Expired";
        }

        // 2. Near expiry ONLY if NOT expired
        elseif ($expTs > $todayTs && $expTs <= $soonTs) {
            $alertsToCreate[] = "Expiring Soon";
        }
    }

    foreach ($alertsToCreate as $type) {
        $exists = $pdo->prepare("
            SELECT COUNT(*) FROM itemAlert
            WHERE itemId = :id AND type = :t
        ");
        $exists->execute([':id' => $itemId, ':t' => $type]);

        if ($exists->fetchColumn() == 0) {
            $insert = $pdo->prepare("
                INSERT INTO itemAlert (itemId, type, generatedAt)
                VALUES (:id, :t, NOW())
            ");
            $insert->execute([
                ':id' => $itemId,
                ':t' => $type
            ]);
        }
    }
}

// FETCH ALL ALERTS FOR SIDEBAR (latest first)
$alertStmt = $pdo->query("
    SELECT a.*, i.itemName, i.quantity, i.unit, i.expirationDate
    FROM itemAlert a
    JOIN items i ON a.itemId = i.itemId
    ORDER BY generatedAt DESC
");
$alerts = $alertStmt->fetchAll();


// GROUP ALERTS BY CATEGORY and attach extras (qty/unit/days left)
$groupedAlerts = [
    "Low Stock"      => [],
    "Out of Stock"   => [],
    "Expiring Soon"  => [],
    "Expired"        => []
];

foreach ($alerts as $a) {
    $itemId = $a['itemId'];

    if (!isset($itemsById[$itemId])) {
        $a['extra'] = '';
        continue;
    }

    $item = $itemsById[$itemId];
    $qty  = (int)$item['quantity'];
    $unit = $item['unit'] ?? '';
    $expDate = $item['expirationDate'] ?? null;

    if ($a['type'] === "Low Stock") {
        $a['extra'] = "{$qty} {$unit} remaining";
        $groupedAlerts["Low Stock"][] = $a;
    } elseif ($a['type'] === "Out of Stock") {
        $groupedAlerts["Out of Stock"][] = $a;
    } elseif ($a['type'] === "Expiring Soon") {
        // Check again if item is already expired — if yes, SKIP
        $expTs = strtotime($expDate);
        if ($expTs < $todayTs) {
            continue;
        }

        // Only show days remaining for valid future expiry dates
        if (!empty($expDate) && $expDate !== "9999-12-31 00:00:00") {
            $daysRemaining = (int)floor(($expTs - $todayTs) / 86400);
            $a['extra'] = "{$daysRemaining} day" . ($daysRemaining !== 1 ? 's' : '') . " left";
        } else {
            $a['extra'] = "Non-expiring";
        }

        $groupedAlerts["Expiring Soon"][] = $a;
    } elseif ($a['type'] === "Expired") {
        $a['extra'] = "{$qty} {$unit}";
        $groupedAlerts["Expired"][] = $a;
    } else {
    }
}

// DELETE ITEM HANDLER
if ($_SERVER["REQUEST_METHOD"] === "POST" && isset($_POST['deleteItemId'])) {

    $itemId = intval($_POST['deleteItemId']);

    $pdo->prepare("DELETE FROM items WHERE itemId = ?")->execute([$itemId]);
    $pdo->prepare("DELETE FROM itemAlert WHERE itemId = ?")->execute([$itemId]);

    header("Location: clinic-inventory.php?deleted=1");
    exit;
}


// ADD NEW ITEM — FORM HANDLER
if ($_SERVER["REQUEST_METHOD"] === "POST" && isset($_POST['itemName']) && isset($_POST['quantity'])) {

    $itemName = $_POST['itemName'];
    $category = $_POST['category'];
    $unit = $_POST['unit'];
    $description = $_POST['description'] ?? "";

    $qty = (int)$_POST['quantity'];
    $nonExp = isset($_POST['nonExp']);

    $expDate = $nonExp ? "9999-12-31 00:00:00" :
               (!empty($_POST['expirationDate']) ? $_POST['expirationDate'] : null);

    if ($qty == 0) $status = "Out of Stock";
    elseif ($qty <= 5) $status = "Low Stock";
    else $status = "In Stock";

    $insert = $pdo->prepare("
        INSERT INTO items (itemName, category, unit, description, quantity, status, expirationDate)
        VALUES (:name, :cat, :unit, :desc, :qty, :status, :exp)
    ");

    $insert->execute([
        ':name' => $itemName,
        ':cat' => $category,
        ':unit' => $unit,
        ':desc' => $description,
        ':qty' => $qty,
        ':status' => $status,
        ':exp' => $expDate
    ]);

    header("Location: clinic-inventory.php?added=1");
    exit;
}

//UPDATE HANDLER
if ($_SERVER["REQUEST_METHOD"] === "POST" && isset($_POST['itemId']) && !isset($_POST['deleteItemId'])) {

    $id    = intval($_POST['itemId']);
    $name  = $_POST['itemName'];
    $cat   = $_POST['category'];
    $unit  = $_POST['unit'];
    $desc  = $_POST['description'] ?? "";

    $current = (int)$itemsById[$id]['quantity'];
    $add     = (int)($_POST['addStock'] ?? 0);
    $reduce  = (int)($_POST['reduceStock'] ?? 0);
    $newQty  = max(0, $current + $add - $reduce);

    $expDate = $_POST['expirationDate'];
    if ($expDate === "" || $expDate === null) 
        $expDate = "9999-12-31 00:00:00";

    if ($newQty == 0) $status = "Out of Stock";
    elseif ($newQty <= 5) $status = "Low Stock";
    else $status = "In Stock";

    $update = $pdo->prepare("
        UPDATE items
        SET itemName = ?, category = ?, unit = ?, description = ?, quantity = ?, status = ?, expirationDate = ?
        WHERE itemId = ?
    ");
    $update->execute([$name, $cat, $unit, $desc, $newQty, $status, $expDate, $id]);

    header("Location: clinic-inventory.php?updated=1");
    exit;
}


?>
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8" />
<title>JoseniCare | Inventory</title>
<meta name="viewport" content="width=device-width, initial-scale=1" />

<link rel="preload" href="<?php echo $basePath; ?>/dist/css/adminlte.css" as="style" />
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fontsource/source-sans-3@5.0.12/index.css" media="print" onload="this.media='all'">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/overlayscrollbars@2.11.0/styles/overlayscrollbars.min.css" />
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css" />
<link rel="stylesheet" href="<?php echo $basePath; ?>/dist/css/adminlte.css" />

<style>
body {
    background: #f5f6f8;
    margin: 0;
}

.page {
    display:flex; min-height:100vh;
}

.main-content {
    flex:1; padding:36px;
}

.title {
    font-size:80px; font-weight:800; color:#123c24;
}

.stats { 
    display:flex; gap:22px; margin:25px 0; }

.stat-box {
    background: #ffffff;
    padding: 20px 28px;
    border-radius: 16px;
    width: 330px;
    height: 118px;
    box-shadow: 0 4px 14px rgba(0,0,0,0.08);
    display: flex;
    align-items: center;
    gap: 18px;
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

.search-row { 
    display:flex; 
    gap:12px; 
    margin:28px 0; 
    height: 35px; 
    align-items: center;
    width: 100;
}

.search-row input {
    flex: 1;
    width:50%; 
    padding:12px; 
    border-radius:10px; 
    border:2px solid #dcdcdc;
    font-size:  16px; 
    height: 40px;
}

.btn-search {
    padding: 5px 18px;
    background: #34703A;
    color: #fff;
    border-radius: 7px;
    border: none;
    font-weight: 500;
    width: 10rem;
    height: 35px;
}

.btn-grey, #editBtn {
    padding: 5px 18px;
    background: #efefef;
    border-radius: 7px;
    border: 1px solid #d6d6d6;
    width: 10rem;
    height: 35px;
    color:#000000;
    box-shadow: 1px 1px 1px rgba(0, 0, 0, 0.50);
}

.btn-reset {
    padding: 5px 18px;
    background: #8B0303;
    border-radius: 7px;
    border: 1px solid #d6d6d6;
    width: 10rem;
    height: 35px;
    color: #fff;
    text-decoration: none;
    text-align: center;
}

.layout { display:flex; gap:26px; }

.table-wrap {
    background:#fff; padding:10px 20px; border-radius:18px;
    flex:1; box-shadow:0 4px 16px rgba(0,0,0,0.06);
}

.inventory tbody tr {
    cursor:pointer;
    transition: background 0.2s;
}

.has-alert {
    background-color: #ffe3dd  !important;
}

.has-alert:hover {
    background-color: #ffd5cd  !important;
}

.inventory tbody tr:hover {
    background:#eaf7ef;
}

.inventory { 
    width:100%; 
    border-collapse:collapse; 
    text-align: center;
}

.inventory th {
    font-weight: 700;
    font-size: 14px;
    padding: 14px 10px;
    color: #555;
    background: #fafafa;
}

.inventory td {
    padding: 14px 10px;
    border-bottom: 1px solid #eee;
    font-size: 15px;
}

/* ----- SIDEBAR ALERTS ----- */
.alerts-panel {
    width: 480px;
    background: #ffffff;
    padding: 20px;
    border-radius: 18px;
    box-shadow: 0 4px 16px rgba(0,0,0,0.1);
}

.alert-header {
    font-size: 22px;
    font-weight: 800;
    margin-bottom: 18px;
}

.alerts { 
    width:320px; 
    background:#fff; 
    padding:14px; 
    border-radius:12px; 
    box-shadow:0 6px 18px rgba(0,0,0,0.08); 
}

.alert-section {
    padding: 15px;
    margin-bottom: 20px;
    box-shadow: 0px 0px 6px 1px rgba(0, 0, 0, 0.25); 
    border-radius: 15px; 
}

.alert-title-yellow {
    font-weight: 700;
    font-size: 14px;
    background: #FFD000;  
    border-radius: 25px; 
    display: inline-block; 
    padding:5px 20px;
    color: #3C3C3C;
}

.alert-title-pink {
    font-weight: 700;
    font-size: 14px;
    background: #FFC7AB;  
    border-radius: 25px; 
    display: inline-block; 
    padding:5px 20px;
    color: #3C3C3C;
}

.alert-pill-yellow {
    padding: 4px 10px;
    font-size: 12px;
    border-radius: 6px;
    background: #FFE46D;
    width: 138.26px; 
    height: 24px; 
    left: 0px; 
    top: 0px;
    box-shadow: 0px 0px 3px #675503 inset; 
    border-radius: 6px;
    font-weight: 400;
    text-align: center;
    color: #3C2C00;
}


.alert-pill-pink {
    padding: 4px 10px;
    font-size: 12px;
    border-radius: 6px;
    background: #FFC9AF;
    width: 138.26px; 
    height: 24px; 
    left: 0px; 
    top: 0px;
    box-shadow: 0px 0px 3px #6A1900 inset; 
    border-radius: 6px;
    font-weight: 400;
    text-align: center;
    color: #750000;
}

.alert-item-yellow {
    margin-top: 10px;
    padding: 8px 0;
    display: flex;
    justify-content: space-between;
    border-bottom: 1px solid #eee;
    font-size: 18px;
    font-weight: 700;
    color: #3C2C00;
}

.alert-item-pink {
    margin-top: 10px;
    padding: 8px 0;
    display: flex;
    justify-content: space-between;
    border-bottom: 1px solid #eee;
    font-size: 18px;
    font-weight: 700;
    color: #3C0000;
}

/* LEFT NAV SIDEBAR */
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
    width: 10%;
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
    font-size: 18px;
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
</style>

</head>

<body>
<div class="page">

    <aside class="sidebar">
        <div class="sidebar-logo">
            <img src="../dist/assets/img/josecare-logo.png" alt="JoseniCare Logo">
        </div>

        <nav class="sidebar-nav">
            <a href="clinic-dashboard.php" class="nav-item">
                <i class="bi bi-grid-fill"></i>
            </a>
            <a href="clinic-appointments.php" class="nav-item">
                <i class="bi bi-calendar2-check"></i>
            </a>
            <a href="clinic-patient-records.php" class="nav-item">
                <i class="bi bi-folder2-open"></i>
            </a>
            <a href="clinic-survey.php" class="nav-item">
                <i class="bi bi-clipboard-pulse"></i>
            </a>
            <a href="clinic-inventory.php" class="nav-item active">
                <i class="bi bi-box-seam"></i>
            </a>
            <a href="clinic-settings.php" class="nav-item">
                <i class="bi bi-gear"></i>
            </a>
        </nav>
    </aside>

    <div class="main-content">

        <div class="title">INVENTORY</div>

        <?php if ($error): ?>
            <div class="alert alert-danger mt-3"><?= htmlspecialchars($error) ?></div>
        <?php endif; ?>
        <?php if ($success): ?>
            <div class="alert alert-success mt-3"><?= htmlspecialchars($success) ?></div>
        <?php endif; ?>

        <div class="stats">
            <div class="stat-box">
                <div class="stat-icon"></div>
                <div>
                    <div class="stat-label">Total Items in Stock</div>
                    <div class="stat-num"><?= $totalItemsInStock ?></div>
                </div>
            </div>

            <div class="stat-box">
                <div class="stat-icon"></div>
                <div>
                    <div class="stat-label">Low-Stock Items</div>
                    <div class="stat-num"><?= $lowStock ?></div>
                </div>
            </div>

            <div class="stat-box">
                <div class="stat-icon"></div>
                <div>
                    <div class="stat-label">Out-of-Stock Items</div>
                    <div class="stat-num"><?= $outOfStock ?></div>
                </div>
            </div>

            <div class="stat-box">
                <div class="stat-icon" style="background:#ffd1d1;"></div>
                <div>
                    <div class="stat-label">Expiring Soon (within 30 days)</div>
                    <div class="stat-num" style="color:#8B0303;"><?= $expiringSoon ?></div>
                </div>
            </div>
    </div>

<!-- SEARCH BAR -->
<form class="search-row" method="get">

    <input type="text" name="q" placeholder="input item name here..." 
           value="<?= htmlspecialchars($search) ?>">

    <!-- SORT DROPDOWN -->
    <select name="sort" class="btn-grey" style="height:35px;">
        <option value="" disabled hidden selected>Sort By...</option>
        <option value="name_asc"  <?= $sort==='name_asc'?'selected':'' ?>>Name (A–Z)</option>
        <option value="name_desc" <?= $sort==='name_desc'?'selected':'' ?>>Name (Z–A)</option>
        <option value="qty_asc"   <?= $sort==='qty_asc'?'selected':'' ?>>Quantity (Low → High)</option>
        <option value="qty_desc"  <?= $sort==='qty_desc'?'selected':'' ?>>Quantity (High → Low)</option>
        <option value="exp_asc"   <?= $sort==='exp_asc'?'selected':'' ?>>Expiration (Soonest First)</option>
        <option value="exp_desc"  <?= $sort==='exp_desc'?'selected':'' ?>>Expiration (Latest First)</option>
    </select>

    <!-- FILTER DROPDOWN -->
    <select name="filter" class="btn-grey" style="height:35px;">
        <option value="" disabled hidden selected>Filter...</option>
        <option value="low_stock" <?= $filter==='low_stock'?'selected':'' ?>>Low Stock</option>
        <option value="out_stock" <?= $filter==='out_stock'?'selected':'' ?>>Out of Stock</option>
        <option value="exp_soon"  <?= $filter==='exp_soon'?'selected':'' ?>>Near Expiry (30 days)</option>
        <option value="expired"   <?= $filter==='expired'?'selected':'' ?>>Expired</option>
        <option value="nonexp"    <?= $filter==='nonexp'?'selected':'' ?>>Non-expiring</option>
    </select>

    <button type="submit" class="btn-search">Search</button>

    <a href="clinic-inventory.php" class="btn-reset">
        Clear Filters 
    </a>

    <button type="button" class="btn-grey" id="addButton">Add Item</button>
</form>


<div style="display:flex; gap:26px;">

    <!-- TABLE -->
    <div class="table-wrap">
        <table class="inventory">
            <thead>
                <tr>
                    <th>Item Name</th>
                    <th>Category</th>
                    <th>Stock Quantity</th>
                    <th>Unit</th>
                    <th>Status</th>
                    <th>Expiration Date</th>
                </tr>
            </thead>

            <tbody>
                <?php foreach ($items as $row): ?>
                    <?php
                        $qty = (int)$row['quantity'];
                        $exp = $row['expirationDate'];
                        $alertClass = "";

                        if ($qty === 0 || ($qty > 0 && $qty <= 5)) {
                            $alertClass = "has-alert";
                        }
                        if ($exp !== "9999-12-31 00:00:00") {
                            $expTs = strtotime($exp);
                            if ($expTs < time() || $expTs <= strtotime("+30 days")) {
                                $alertClass = "has-alert";
                            }
                        }
                    ?>
                <tr class="<?= $alertClass ?>"
                    data-id="<?= $row['itemId'] ?>"
                    data-name="<?= htmlspecialchars($row['itemName']) ?>"
                    data-category="<?= htmlspecialchars($row['category']) ?>"
                    data-qty="<?= $qty ?>"
                    data-unit="<?= htmlspecialchars($row['unit']) ?>"
                    data-status="<?= htmlspecialchars($row['status']) ?>"
                    data-exp="<?= $row['expirationDate'] ?>"
                    data-desc="<?= htmlspecialchars($row['description']) ?>"
                >
                    <td><?= htmlspecialchars($row['itemName']) ?></td>
                    <td><?= htmlspecialchars($row['category']) ?></td>
                    <td><?= $qty ?></td>
                    <td><?= htmlspecialchars($row['unit']) ?></td>
                    <td><?= htmlspecialchars($row['status']) ?></td>
                    <td>
                        <?= ($row['expirationDate'] === "9999-12-31 00:00:00") 
                            ? "Non-expiring" 
                            : date("M d, Y", strtotime($row['expirationDate'])) 
                        ?>
                    </td>
                </tr>

                <?php endforeach; ?>
            </tbody>
        </table>
    </div>

    <!-- ALERT SIDEBAR -->
    <div class="alerts-panel">
        <div class="alert-header">Inventory Alerts</div>

        <!-- HEALTH TREND DEMAND -->
        <div class="alert-section" style="background:#FFF0AF; border: 2px #867111 solid;">
            <div class="alert-title-yellow">HEALTH TREND DEMAND</div>
                <!-- wala pay health demand data -->
        
        </div>

        <!-- LOW STOCK -->
        <div class="alert-section" style="background:#FFF0AF; border: 2px #867111 solid;">
            <div class="alert-title-yellow">LOW STOCK</div>

            <?php foreach ($groupedAlerts["Low Stock"] as $a): ?>
                <div class="alert-item-yellow">
                    <div>⚠ <?= htmlspecialchars($a['itemName']) ?></div>
                    <span class="alert-pill-yellow"><?= htmlspecialchars($a['extra']) ?></span>
                </div>
            <?php endforeach; ?>
        </div>

        <!-- OUT OF STOCK -->
        <div class="alert-section" style="background:#ffe0dd; border: 2px #863411 solid;">
            <div class="alert-title-pink">OUT-OF-STOCK</div>

            <?php foreach ($groupedAlerts["Out of Stock"] as $a): ?>
                <div class="alert-item-pink">
                    <div>⚠ <?= htmlspecialchars($a['itemName']) ?></div>
                </div>
            <?php endforeach; ?>
        </div>

        <!-- NEAR EXPIRY -->
        <div class="alert-section" style="background:#FFE4E4; border: 2px #863411 solid;">
            <div class="alert-title-pink">NEAR EXPIRY</div>

            <?php foreach ($groupedAlerts["Expiring Soon"] as $a): ?>
                <div class="alert-item-pink">
                    <div>⚠ <?= htmlspecialchars($a['itemName']) ?></div>
                    <span class="alert-pill-pink"><?= htmlspecialchars($a['extra']) ?></span>
                </div>
            <?php endforeach; ?>
        </div>

        <!-- EXPIRED -->
        <div class="alert-section" style="background:#ffe9dc; border: 2px #863411 solid;">
            <div class="alert-title-pink">EXPIRED</div>

            <?php foreach ($groupedAlerts["Expired"] as $a): ?>
                <div class="alert-item-pink">
                    <div>⚠ <?= htmlspecialchars($a['itemName']) ?></div>
                    <span class="alert-pill-pink"><?= htmlspecialchars($a['extra']) ?></span>
                </div>
            <?php endforeach; ?>
        </div>
    </div>

</div>

<!-- ITEM DETAILS MODAL -->
<div class="modal fade" id="itemModal" tabindex="-1">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content" style="border-radius:16px;">

      <div class="modal-header">
        <h4 class="modal-title">Item Details</h4>
      </div>

      <div class="modal-body">

        <h5 class="info-header"><strong>ITEM INFORMATION</strong></h5>
        <p><strong>Name:</strong> <span id="m_name" style="padding-left: 53px;"></span></p>
        <p><strong>Category:</strong> <span id="m_category" style="padding-left: 29px;"></span></p>
        <p><strong>Unit:</strong> <span id="m_unit" style="padding-left: 67px;"></span></p>
        <p><strong>Description:</strong> <span id="m_desc" style="padding-left: 12px;"></span></p>

        <hr>

        <h5 class="info-header"><strong>STOCK DETAILS</strong></h5>
        <p><strong>Quantity:</strong> <span id="m_qty" style="padding-left: 29px;"></span></p>
        <p><strong>Status:</strong> <span id="m_status" style="padding-left: 49px;"></span></p>
        <p><strong>Expiration:</strong> <span id="m_exp" style="padding-left: 17px;"></span></p>

        <div id="alertBox" class="mt-3 p-3 border rounded" style="display:none;">
            <strong>ALERTS & IMPORTANT NOTES</strong>
            <ul id="alertList"></ul>
        </div>

      </div>

      <div class="modal-footer">
        <a id="editBtn" class="btn btn-primary">Update Item</a>
        <button class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
      </div>

    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/js/bootstrap.bundle.min.js"></script>

    <script>
    document.querySelectorAll(".inventory tbody tr").forEach(row => {
        row.addEventListener("click", () => {

            document.getElementById("m_name").textContent = row.dataset.name;
            document.getElementById("m_category").textContent = row.dataset.category;
            document.getElementById("m_unit").textContent = row.dataset.unit;
            document.getElementById("m_qty").textContent = row.dataset.qty;
            document.getElementById("m_status").textContent = row.dataset.status;
            document.getElementById("m_exp").textContent =
                row.dataset.exp === "9999-12-31 00:00:00" ? "Non-expiring" : row.dataset.exp;
            document.getElementById("m_desc").textContent = row.dataset.desc || "—";

            document.getElementById("editBtn").onclick = () => {
                bootstrap.Modal.getInstance(document.getElementById("itemModal")).hide();

                setUpdateModalValues(row);
                new bootstrap.Modal(document.getElementById("updateItemModal")).show();
            };


            // Alerts inside the modal
            let alerts = [];
            if (parseInt(row.dataset.qty) <= 5) alerts.push("⚠ Low stock");
            if (row.dataset.exp !== "9999-12-31 00:00:00") {
                let exp = new Date(row.dataset.exp);
                let soon = new Date(Date.now() + 60*24*3600*1000);
                if (exp <= soon && exp >= new Date()) alerts.push("⚠ Expiring Soon");
                if (exp < new Date()) alerts.push("⚠ Already expired");
            }

            const alertBox = document.getElementById("alertBox");
            const alertList = document.getElementById("alertList");
            alertList.innerHTML = "";

            if (alerts.length > 0) {
                alertBox.style.display = "block";
                alerts.forEach(a => {
                    let li = document.createElement("li");
                    li.textContent = a;
                    alertList.appendChild(li);
                });
            } else {
                alertBox.style.display = "none";
            }

            new bootstrap.Modal(document.getElementById("itemModal")).show();
        });
    });
    </script>


<!-- ADD ITEM MODAL -->
<div class="modal fade" id="addItemModal" tabindex="-1">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content" style="border-radius:16px;">

      <div class="modal-header">
        <h4 class="modal-title">Add New Inventory Item</h4>
      </div>

      <form method="POST" id="addItemForm">

        <div class="modal-body">

          <h5 class="info-header"><strong>ITEM INFORMATION</strong></h5>

          <label>Item Name:</label>
          <input type="text" class="form-control mb-2" name="itemName" required>

          <label>Category:</label>
          <input type="text" class="form-control mb-2" name="category" placeholder="Medicine, First Aid, PPE..." required>

          <label>Unit:</label>
          <input type="text" class="form-control mb-2" name="unit" placeholder="Tablets, box, pack..." required>

          <label>Description:</label>
          <input type="text" class="form-control mb-3" name="description" placeholder="Optional short description...">

          <hr>

          <h5 class="info-header"><strong>INITIAL STOCK DETAILS</strong></h5>

          <label>Initial Quantity:</label>
          <input type="number" min="0" class="form-control mb-2" name="quantity" id="qtyInput" value="0">

          <label>Expiration Date:</label>
          <input type="date" class="form-control mb-2" name="expirationDate" id="expInput">

          <div class="form-check my-2">
            <input class="form-check-input" type="checkbox" id="nonExp" name="nonExp">
            <label class="form-check-label">This item does not expire.</label>
          </div>

          <hr>

          <h5 class="info-header"><strong>STATUS PREVIEW</strong> <span class="text-muted">(auto-calculated)</span></h5>

          <p><strong>New Status:</strong> <span id="prevStatus">IN STOCK</span></p>
          <p><strong>Expiring Soon?:</strong> <span id="prevExp">NO</span></p>

        </div>

        <div class="modal-footer">
          <button type="submit" class="btn btn-primary">Add Item</button>
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
        </div>

      </form>

    </div>
  </div>
</div>

    <script>
    document.getElementById("addButton").addEventListener("click", () => {
        new bootstrap.Modal(document.getElementById("addItemModal")).show();
    });

    function updatePreview() {
        let qty = parseInt(document.getElementById("qtyInput").value || 0);
        let exp = document.getElementById("expInput").value;
        let noExp = document.getElementById("nonExp").checked;

        let status = "IN STOCK";
        if (qty === 0) status = "OUT OF STOCK";
        else if (qty > 0 && qty <= 5) status = "LOW STOCK";

        document.getElementById("prevStatus").textContent = status;

        if (noExp || exp === "") {
            document.getElementById("prevExp").textContent = "NO";
            return;
        }

        let expDate = new Date(exp);
        let today = new Date();
        let soon = new Date(Date.now() + 30 * 24 * 3600 * 1000);

        if (expDate <= soon && expDate > today) {
            document.getElementById("prevExp").textContent = "YES";
        } else {
            document.getElementById("prevExp").textContent = "NO";
        }
    }

    document.getElementById("qtyInput").addEventListener("input", updatePreview);
    document.getElementById("expInput").addEventListener("input", updatePreview);
    document.getElementById("nonExp").addEventListener("change", () => {
        document.getElementById("expInput").disabled = document.getElementById("nonExp").checked;
        updatePreview();
    });
    </script>

<!-- UPDATE ITEM MODAL -->
<div class="modal fade" id="updateItemModal" tabindex="-1">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content" style="border-radius:16px;">

      <div class="modal-header">
        <h4 class="modal-title">Update Item</h4>
      </div>

      <form method="POST" id="updateItemForm">

        <div class="modal-body">

          <h5 class="info-header"><strong>ITEM INFORMATION</strong></h5>

          <label>Item Name:</label>
          <input type="text" class="form-control mb-2" name="itemName" id="u_name" required>

          <label>Category:</label>
          <input type="text" class="form-control mb-2" name="category" id="u_category" required>

          <label>Unit:</label>
          <input type="text" class="form-control mb-2" name="unit" id="u_unit" required>

          <label>Description:</label>
          <input type="text" class="form-control mb-3" name="description" id="u_desc">

          <hr>

          <h5 class="info-header"><strong>STOCK ADJUSTMENTS</strong></h5>

          <p><strong>Current Quantity:</strong> <span id="u_currentQty"></span></p>

          <div class="row">
            <div class="col-6">
              <label>Add Stock:</label>
              <input type="number" min="0" class="form-control mb-2" id="u_add" name="addStock">
            </div>

            <div class="col-6">
              <label>Reduce Stock:</label>
              <input type="number" min="0" class="form-control mb-2" id="u_reduce" name="reduceStock">
            </div>
          </div>

          <label>Expiration Date:</label>
          <input type="date" class="form-control mb-3" name="expirationDate" id="u_exp">

          <hr>

          <h5 class="info-header"><strong>STATUS PREVIEW</strong> <span class="text-muted">(auto-calculated)</span></h5>

          <p><strong>New Quantity:</strong> <span id="u_prevQty"></span></p>
          <p><strong>New Status:</strong> <span id="u_prevStatus"></span></p>
          <p><strong>Expiring Soon?:</strong> <span id="u_prevExp"></span></p>

        </div>

        <div class="modal-footer">
          <button type="submit" class="btn btn-primary">Save Changes</button>
          <button type="button" class="btn btn-danger" id="deleteItemBtn">Delete Item</button>
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
        </div>

        <input type="hidden" name="itemId" id="u_id">
      </form>

    </div>
  </div>
</div>

    <script>
    function updateUpdatePreview() {
        let current = parseInt(document.getElementById("u_currentQty").textContent);
        let add = parseInt(document.getElementById("u_add").value || 0);
        let reduce = parseInt(document.getElementById("u_reduce").value || 0);

        let newQty = current + add - reduce;
        if (newQty < 0) newQty = 0;

        document.getElementById("u_prevQty").textContent = newQty;

        let status = "In Stock";
        if (newQty === 0) status = "Out of Stock";
        else if (newQty <= 5) status = "Low Stock";

        document.getElementById("u_prevStatus").textContent = status;

        let exp = document.getElementById("u_exp").value;
        let expSoon = "NO";

        if (exp) {
            let expDate = new Date(exp);
            let today = new Date();
            let soon = new Date(Date.now() + 30 * 24 * 3600 * 1000);

            if (expDate <= soon && expDate > today) expSoon = "YES";
            if (expDate < today) expSoon = "EXPIRED";
        }

        document.getElementById("u_prevExp").textContent = expSoon;
    }

    document.getElementById("u_add").addEventListener("input", updateUpdatePreview);
    document.getElementById("u_reduce").addEventListener("input", updateUpdatePreview);
    document.getElementById("u_exp").addEventListener("input", updateUpdatePreview);

    document.getElementById("deleteItemBtn").addEventListener("click", () => {
        if (confirm("Are you sure you want to delete this item?")) {

            let form = document.createElement("form");
            form.method = "POST";
            form.innerHTML = `
                <input type="hidden" name="deleteItemId" value="${document.getElementById("u_id").value}">
            `;
            document.body.appendChild(form);
            form.submit();
        }
    });

    function setUpdateModalValues(row) {
        document.getElementById("u_id").value = row.dataset.id;
        document.getElementById("u_name").value = row.dataset.name;
        document.getElementById("u_category").value = row.dataset.category;
        document.getElementById("u_unit").value = row.dataset.unit;
        document.getElementById("u_desc").value = row.dataset.desc || "";
        document.getElementById("u_currentQty").textContent = row.dataset.qty;
        document.getElementById("u_add").value = "";
        document.getElementById("u_reduce").value = "";
        document.getElementById("u_exp").value =
            row.dataset.exp === "9999-12-31 00:00:00" ? "" : row.dataset.exp;

        updateUpdatePreview();
    }

    </script>

</body>
</html>