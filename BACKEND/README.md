# JoseniCare Backend Setup Instructions

## Prerequisites
- XAMPP or WAMP (for Apache and MySQL/phpMyAdmin)
- PHP 7.4 or higher
- Flutter SDK installed

## Database Setup

### 1. Start XAMPP/WAMP
- Start Apache and MySQL services

### 2. Create Database
1. Open phpMyAdmin in your browser: `http://localhost/phpmyadmin`
2. Click on "SQL" tab
3. Copy and paste the contents of `/backend/database.sql`
4. Click "Go" to execute the SQL commands

This will:
- Create a database named `josenicare_db`
- Create a `users` table with email and password fields

### 3. Configure Database Connection
The database configuration is in `/backend/config/database.php`:
```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'josenicare_db');
define('DB_USER', 'root');      // Default phpMyAdmin username
define('DB_PASS', '');          // Default phpMyAdmin password (empty)
```

**If you have a different MySQL configuration**, update these values accordingly.

## Backend Setup

### 1. Move Backend Files to Server Directory
Copy the entire `backend` folder to your web server directory:

**For XAMPP:**
- Windows: `C:\xampp\htdocs\SE-JoseniCare\backend`
- macOS: `/Applications/XAMPP/htdocs/SE-JoseniCare/backend`
- Linux: `/opt/lampp/htdocs/SE-JoseniCare/backend`

**For WAMP:**
- Windows: `C:\wamp64\www\SE-JoseniCare\backend`

### 2. Test Backend Endpoints
Open your browser and test the endpoints:
- Login: `http://localhost/SE-JoseniCare/backend/api/login.php`
- Signup: `http://localhost/SE-JoseniCare/backend/api/signup.php`

You should see a JSON error message (because you didn't send data), which means the endpoint is working.

## Flutter App Configuration

### 1. Update API Base URL
Open `/lib/services/api_service.dart` and update the `baseUrl` based on your testing environment:

**For Web (Chrome/Edge):**
```dart
static const String baseUrl = 'http://localhost/SE-JoseniCare/backend/api';
```

**For Android Emulator:**
```dart
static const String baseUrl = 'http://10.0.2.2/SE-JoseniCare/backend/api';
```

**For iOS Simulator:**
```dart
static const String baseUrl = 'http://localhost/SE-JoseniCare/backend/api';
// or
static const String baseUrl = 'http://127.0.0.1/SE-JoseniCare/backend/api';
```

**For Physical Android/iOS Device:**
Find your computer's IP address:
- Windows: Open CMD and run `ipconfig` (look for IPv4 Address)
- macOS/Linux: Open Terminal and run `ifconfig` or `ip addr` (look for inet)

Then use:
```dart
static const String baseUrl = 'http://YOUR_COMPUTER_IP/SE-JoseniCare/backend/api';
// Example: static const String baseUrl = 'http://192.168.1.100/SE-JoseniCare/backend/api';
```

### 2. Install Flutter Dependencies
```bash
flutter pub get
```

### 3. Run the App
```bash
flutter run
```

## Testing the Integration

### 1. Create a Test Account
1. Open the app
2. Click "Sign up"
3. Enter an email and password (minimum 6 characters)
4. Check the privacy policy checkbox
5. Click "SIGN UP"
6. You should see "Account created successfully" message

### 2. Login with Test Account
1. On the login page, enter the email and password you just created
2. Click "LOGIN"
3. You should see "Login successful" message

### 3. Verify in Database
1. Open phpMyAdmin: `http://localhost/phpmyadmin`
2. Select `josenicare_db` database
3. Click on `users` table
4. You should see your registered user

## Troubleshooting

### "Network error" message
- Make sure Apache is running in XAMPP/WAMP
- Check that the `baseUrl` in `api_service.dart` is correct
- Try accessing the API URL directly in your browser

### "Database connection failed"
- Check that MySQL is running in XAMPP/WAMP
- Verify database credentials in `/backend/config/database.php`
- Make sure you've created the database using `database.sql`

### CORS errors (in browser console)
- The PHP files already include CORS headers
- Clear browser cache and try again

### "Email already registered"
- The email you're trying to register already exists in the database
- Try a different email or delete the user from phpMyAdmin

## API Endpoints

### POST /api/signup.php
Create a new user account

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Success Response (201):**
```json
{
  "success": true,
  "message": "Account created successfully",
  "data": {
    "id": 1,
    "email": "user@example.com"
  }
}
```

**Error Response (409):**
```json
{
  "success": false,
  "message": "Email already registered"
}
```

### POST /api/login.php
Login with existing account

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "id": 1,
    "email": "user@example.com"
  }
}
```

**Error Response (401):**
```json
{
  "success": false,
  "message": "Invalid email or password"
}
```

## Security Notes

⚠️ **This is a basic implementation for development/learning purposes.**

For production, you should:
- Use HTTPS instead of HTTP
- Implement JWT tokens for session management
- Add rate limiting to prevent brute force attacks
- Use prepared statements (already implemented)
- Add input validation and sanitization (partially implemented)
- Store sensitive configuration in environment variables
- Implement password reset functionality
- Add email verification
