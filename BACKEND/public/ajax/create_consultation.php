<?php
require_once __DIR__ . '/../../config/session.php';
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../config/database.php';

header("Content-Type: application/json");

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    echo json_encode(["success" => false, "message" => "Invalid request."]);
    exit;
}

$pdo = getDbConnection();

$studentId = $_POST["studentId"] ?? null;

if (!$studentId) {
    echo json_encode(["success" => false, "message" => "Missing student ID."]);
    exit;
}

// Find patient recordId
$stmt = $pdo->prepare("SELECT recordId FROM patientRecord WHERE studentId = :sid LIMIT 1");
$stmt->execute([":sid" => $studentId]);
$recordId = $stmt->fetchColumn();

if (!$recordId) {
    echo json_encode(["success" => false, "message" => "Patient record not found."]);
    exit;
}

try {

    // Create NEW consultation
    $sql = "INSERT INTO consultationRecord (recordId, date) VALUES (:rid, NOW())";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([":rid" => $recordId]);

    $newConsultId = $pdo->lastInsertId();

    echo json_encode([
        "success" => true,
        "consultationId" => $newConsultId
    ]);
    exit;

} catch (Exception $e) {

    echo json_encode([
        "success" => false,
        "message" => $e->getMessage()
    ]);
    exit;
}
