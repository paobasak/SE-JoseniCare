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

$consultationId = $_POST["consultationId"] ?? null;
$reason         = $_POST["reason"] ?? null;
$temp           = $_POST["temp"] ?? null;
$bp             = $_POST["bp"] ?? null;
$pulse          = $_POST["pulse"] ?? null;
$rr             = $_POST["rr"] ?? null;
$diagnosis      = $_POST["diagnosis"] ?? null;
$notes          = $_POST["notes"] ?? null;

if (!$consultationId) {
    echo json_encode(["success" => false, "message" => "Consultation ID missing."]);
    exit;
}

try {

    $sql = "INSERT INTO assessment 
            (consultationId, reason_for_visit, temperature, blood_pressure, pulse_rate, respiratory_rate, diagnosis, notes, created_at)
            VALUES 
            (:cid, :reason, :temp, :bp, :pulse, :rr, :diagnosis, :notes, NOW())";

    $stmt = $pdo->prepare($sql);
    $stmt->execute([
        ":cid"       => $consultationId,
        ":reason"    => $reason,
        ":temp"      => $temp,
        ":bp"        => $bp,
        ":pulse"     => $pulse,
        ":rr"        => $rr,
        ":diagnosis" => $diagnosis,
        ":notes"     => $notes
    ]);

    echo json_encode(["success" => true, "message" => "Assessment saved successfully."]);
    exit;

} catch (Exception $e) {

    echo json_encode([
        "success" => false,
        "message" => "Database error: " . $e->getMessage()
    ]);
    exit;
}
