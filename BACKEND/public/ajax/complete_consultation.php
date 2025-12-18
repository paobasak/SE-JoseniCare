<?php
require_once __DIR__ . '/../config/database.php';

try {
    $pdo = getDbConnection();

    if (!isset($_POST['consultationId'])) {
        echo json_encode(["success" => false, "message" => "Missing consultation ID"]);
        exit;
    }

    $consultationId = $_POST['consultationId'];

    // mark consultation as completed
    $stmt = $pdo->prepare("
        UPDATE consultationRecord 
        SET status = 'Completed', completed_at = NOW()
        WHERE consultationId = :id
    ");

    $stmt->execute([":id" => $consultationId]);

    echo json_encode(["success" => true]);
} 
catch (Exception $e) {
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}
