<?php
require_once '../config/database.php';

// Get JSON input
$data = json_decode(file_get_contents("php://input"), true);

// Validate input
if (!isset($data['email']) || !isset($data['password'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Email and password are required'
    ]);
    exit();
}

$email = filter_var($data['email'], FILTER_SANITIZE_EMAIL);
$password = $data['password'];

// Validate email format
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Invalid email format'
    ]);
    exit();
}

// Validate password length
if (strlen($password) < 6) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Password must be at least 6 characters'
    ]);
    exit();
}

try {
    $conn = getDBConnection();
    
    // Check if user already exists
    $stmt = $conn->prepare("SELECT id FROM users WHERE email = :email");
    $stmt->bindParam(':email', $email);
    $stmt->execute();
    
    if ($stmt->fetch()) {
        http_response_code(409);
        echo json_encode([
            'success' => false,
            'message' => 'Email already registered'
        ]);
        exit();
    }
    
    // Hash password
    $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
    
    // Insert new user
    $stmt = $conn->prepare("INSERT INTO users (email, password) VALUES (:email, :password)");
    $stmt->bindParam(':email', $email);
    $stmt->bindParam(':password', $hashedPassword);
    $stmt->execute();
    
    $userId = $conn->lastInsertId();
    
    http_response_code(201);
    echo json_encode([
        'success' => true,
        'message' => 'Account created successfully',
        'data' => [
            'id' => $userId,
            'email' => $email
        ]
    ]);
    
} catch(PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Server error: ' . $e->getMessage()
    ]);
}
?>
