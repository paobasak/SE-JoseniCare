# JoseCare System - Detailed Procedural Design Layout

## Table of Contents
1. [System Overview](#system-overview)
2. [Architecture Layers](#architecture-layers)
3. [Data Flow Procedures](#data-flow-procedures)
4. [Authentication Procedures](#authentication-procedures)
5. [Authorization Procedures](#authorization-procedures)
6. [Session Management Procedures](#session-management-procedures)
7. [Security Procedures](#security-procedures)
8. [Database Procedures](#database-procedures)
9. [UI/Frontend Procedures](#uifrontend-procedures)
10. [Error Handling Procedures](#error-handling-procedures)
11. [Maintenance Procedures](#maintenance-procedures)

---

## System Overview

### System Purpose
JoseCare is a healthcare management system with comprehensive authentication, role-based access control, and session management capabilities.

### Technology Stack
- **Backend**: PHP 8.4
- **Database**: MySQL 5.7+
- **Frontend**: AdminLTE 4.0 (Bootstrap 5)
- **Session Storage**: File-based PHP sessions
- **Security**: Bcrypt hashing, PDO prepared statements

### Core Modules
1. Authentication Module
2. Authorization/RBAC Module
3. Session Management Module
4. User Management Module
5. Security & Audit Module
6. Dashboard Module

---

## Architecture Layers

```
┌─────────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                         │
│  (AdminLTE Templates, HTML Forms, JavaScript Validation)        │
├─────────────────────────────────────────────────────────────────┤
│                      APPLICATION LAYER                          │
│  ┌──────────────┬──────────────┬──────────────┬──────────────┐  │
│  │ Auth Module  │ RBAC Module  │Session Module│ User Module  │  │
│  └──────────────┴──────────────┴──────────────┴──────────────┘  │
├─────────────────────────────────────────────────────────────────┤
│                      BUSINESS LOGIC LAYER                       │
│  ┌──────────────┬──────────────┬──────────────┬──────────────┐  │
│  │  includes/   │  includes/   │   config/    │   config/    │  │
│  │   auth.php   │  roles.php   │ session.php  │ database.php │  │
│  └──────────────┴──────────────┴──────────────┴──────────────┘  │
├─────────────────────────────────────────────────────────────────┤
│                      DATA ACCESS LAYER                          │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │        PDO Connection with Prepared Statements           │   │
│  └──────────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────────┤
│                      DATABASE LAYER                             │
│  ┌──────────────┬──────────────┬──────────────────────────┐     │
│  │ users table  │ roles table  │ remember_tokens table    │     │
│  └──────────────┴──────────────┴──────────────────────────┘     │
└─────────────────────────────────────────────────────────────────┘
```

---

## System Flowcharts

### 1. Complete System Flow Diagram

```
                           ┌──────────────────┐
                           │   User Browser   │
                           └────────┬─────────┘
                                    │
                                    ▼
                       ┌────────────────────────┐
                       │   HTTP Request         │
                       │   (GET/POST)           │
                       └────────┬───────────────┘
                                │
                                ▼
                    ┌───────────────────────────┐
                    │   Web Server              │
                    │   (Apache/Nginx)          │
                    └───────────┬───────────────┘
                                │
                                ▼
                    ┌───────────────────────────┐
                    │   PHP Script Router       │
                    └───────────┬───────────────┘
                                │
                ┌───────────────┼───────────────┐
                │               │               │
                ▼               ▼               ▼
        ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
        │   Public    │ │   Admin     │ │    API      │
        │   Pages     │ │   Pages     │ │  Endpoints  │
        └──────┬──────┘ └──────┬──────┘ └──────┬──────┘
               │               │               │
               │     ┌─────────┴───────┐       │
               │     │                 │       │
               ▼     ▼                 ▼       ▼
        ┌──────────────────────────────────────────┐
        │   Session Management                     │
        │   - Initialize Session                   │
        │   - Validate Authentication              │
        │   - Check Permissions                    │
        └────────────────┬─────────────────────────┘
                         │
                         ▼
        ┌──────────────────────────────────────────┐
        │   Business Logic Layer                   │
        │   - Authentication Functions             │
        │   - Role Management                      │
        │   - Data Validation                      │
        └────────────────┬─────────────────────────┘
                         │
                         ▼
        ┌──────────────────────────────────────────┐
        │   Database Access Layer                  │
        │   - PDO Connection                       │
        │   - Prepared Statements                  │
        │   - Query Execution                      │
        └────────────────┬─────────────────────────┘
                         │
                         ▼
        ┌──────────────────────────────────────────┐
        │   MySQL Database                         │
        │   - users                                │
        │   - roles                                │
        │   - remember_tokens                      │
        └────────────────┬─────────────────────────┘
                         │
                         ▼
        ┌──────────────────────────────────────────┐
        │   Response Generation                    │
        │   - HTML Rendering                       │
        │   - JSON Response                        │
        │   - Redirect                             │
        └────────────────┬─────────────────────────┘
                         │
                         ▼
                ┌────────────────┐
                │  Send Response │
                │  to Browser    │
                └────────────────┘
```

### 2. User Registration Flow

```
        ╭─────────────────╮
        │  START:         │
        │  User Access    │
        │  register.php   │
        ╰────────┬────────╯
                 │
                 ▼
    ╔════════════════════════╗
    ║  OUTPUT: Display Form  ║
    ║  - Full Name           ║
    ║  - Email               ║
    ║  - Password            ║
    ║  - Confirm Pass        ║
    ║  - Role Select         ║
    ║  - Terms Agree         ║
    ╚════════════╤═══════════╝
                 │
                 ▼
    ╔════════════════════════╗
    ║  INPUT: User Fills &   ║
    ║  Submits Form Data     ║
    ╚════════════╤═══════════╝
                 │
                 ▼
    ┌────────────────────────┐
    │  PROCESS:              │
    │  Client-Side           │
    │  Validation (JS)       │
    │  - Email format        │
    │  - Password length ≥8  │
    │  - Passwords match     │
    │  - Terms checked       │
    └─────────────┬──────────┘
                  │
                  ▼
                  /\
                 /  \
                /    \
               /      \
              / Passed?\
              \        /
               \      /
                \    /
                 \  /
                  \/
                  │
         ┌────────┴────────┐
         │                 │
    NO   ▼                 ▼ YES
╔═══════════════╗  ╔═══════════════╗
║  OUTPUT:      ║  ║  OUTPUT:      ║
║  Show Errors  ║  ║  POST Request ║
║  to User      ║  ║  to Server    ║
╚═══════════════╝  ╚═══════╤═══════╝
                        │
                        ▼
           ┌────────────────────────┐
           │  PROCESS:              │
           │  Server-Side           │
           │  Validation            │
           │  1. Sanitize inputs    │
           │  2. Validate email     │
           │  3. Check pass length  │
           │  4. Confirm match      │
           └───────────┬────────────┘
                       │
                       ▼
                       /\
                      /  \
                     /    \
                    /      \
                   / Valid? \
                   \        /
                    \      /
                     \    /
                      \  /
                       \/
                       │
                       │
              ┌────────┴────────┐
              │                 │
          NO  ▼                 ▼ YES
    ┌─────────────────┐   ┌────────────────────┐
    │  PROCESS:       │   │  PROCESS:          │
    │  Set Flash      │   │  Query Database    │
    │  Error Message  │   │  Check Email       │
    │                 │   │  Uniqueness        │
    └────────┬────────┘   └──────────┬─────────┘
                  │                     │
                  │                     ▼                 
                  |                    / \
                  |                   /   \
                  │                  /     \
                  │                 /       \
                  │                / Exists? \
                  │                \        /
                  │                 \      /
                  │                  \    /
                  │                   \  /
                  |                    \/
                  │                     │
                  │                     │
                  │            ┌────────┴────────┐
                  │            │                 │
                  │        YES ▼                 ▼ NO
                  │    ┌────────────────┐  ┌────────────────┐
                  │    │  PROCESS:      │  │  PROCESS:      │
                  │    │  Set Flash     │  │  Validate      │
                  │    │  "Email        │  │  Role ID       │
                  │    │   Already      │  │  Exists        │
                  │    │   Registered"  │  │                │
                  │    └───────┬────────┘  └───────┬────────┘
                  │            │                   │
                  │            │                   ▼
                  │            │          ┌────────────────┐
                  │            │          │  PROCESS:      │
                  │            │          │  Hash Password │
                  │            │          │  (Bcrypt,      │
                  │            │          │   Cost=12)     │
                  │            │          └────────┬───────┘
                  │            │                   │
                  │            │                   ▼
                  │            │          ┌────────────────┐
                  │            │          │  PROCESS:      │
                  │            │          │  INSERT INTO   │
                  │            │          │  users Table   │
                  │            │          │  (email, pass, │
                  │            │          │   role_id)     │
                  │            │          └────────┬───────┘
                  │            │                   │
                  │            │                   ▼
                  │            │                  /\
                  │            │                 /  \
                  |            |                /    \
                  |            |               /      \
                  |            |              /        \
                  │            │             / Success? \
                  │            │             \          /
                  │            │              \        /
                  │            │               \      /
                  │            │                \    /
                  |            |                 \  /
                  |            |                  \/
                  │            │                   │
                  │            │                   │
                  │            │          ┌────────┴────────┐
                  │            │          │                 │
                  │            │      YES ▼                 ▼ NO
                  │            │    ┌──────────────┐  ┌────────────┐
                  │            │    │  PROCESS:    │  │  PROCESS:  │
                  │            │    │  Set Flash   │  │  Set Flash │
                  │            │    │  "Success"   │  │  "DB Error"│
                  │            │    └─────┬────────┘  └─────┬──────┘
                  │            │          │                  │
                  └────────────┴──────────┴──────────────────┘
                                          │
                                          ▼
                                 ╔════════════════╗
                                 ║  OUTPUT:       ║
                                 ║  Redirect to   ║
                                 ║  login.php     ║
                                 ╚════════════════╝
                                          │
                                          ▼
                                 ╭────────────────╮
                                 │      END       │
                                 ╰────────────────╯
```

### 3. User Login Flow

```
        ╭─────────────────╮
        │  START:         │
        │  User Access    │
        │  login.php      │
        ╰────────┬────────╯
                 │
                 ▼
        ┌─────────────────┐
        │  PROCESS:       │
        │  Check Session  │
        │  Status         │
        └────────┬────────┘
                 │
                 ▼
                 /\
                /  \
               /    \
              / Logged \
              \  In?   /
               \      /
                \    /
                 \  /
                  \/
                  │
        ┌────────┴────────┐
        │                 │
    YES ▼                 ▼ NO
╔═══════════════╗   ╔════════════════════╗
║  OUTPUT:      ║   ║  OUTPUT:           ║
║  Redirect to  ║   ║  Display Login     ║
║  Dashboard    ║   ║  Form              ║
╚═══════════════╝   ║  - Email           ║
                    ║  - Password        ║
                    ║  - Remember Me     ║
                    ╚═════════╤══════════╝
                              │
                              ▼
                    ╔═════════════════════╗
                    ║  INPUT:             ║
                    ║  User Enters        ║
                    ║  Credentials        ║
                    ╚══════════╤══════════╝
                          │
                          ▼
                   ┌──────────────┐
                   │  PROCESS:    │
                   │  Client JS   │
                   │  Validation  │
                   └──────┬───────┘
                          │
                          ▼
                          /\
                         /  \
                        /    \
                       /      \
                      / Valid? \
                      \        /
                       \      /
                        \    /
                         \  /
                          \/
                          │
                          │
                 ┌────────┴────────┐
                 │                 │
             NO  ▼                 ▼ YES
         ╔═══════════╗       ╔═════════════╗
         ║  OUTPUT:  ║       ║  OUTPUT:    ║
         ║  Show     ║       ║  POST to    ║
         ║  Errors   ║       ║  Server     ║
         ╚═══════════╝       ╚══════╤══════╝
                              │
                              ▼
                     ┌─────────────────┐
                     │  PROCESS:       │
                     │  Sanitize Input │
                     │  email = trim() │
                     │  pass = trim()  │
                     └────────┬────────┘
                              │
                              ▼
                     ┌─────────────────┐
                     │  PROCESS:       │
                     │  Query User by  │
                     │  Email (JOIN    │
                     │  with roles)    │
                     └────────┬────────┘
                              │
                              ▼
                             /\
                            /  \
                           /    \
                          /      \
                         / Found? \
                         \        /
                          \      /
                           \    /
                            \  /
                             \/
                              │
                              │
                     ┌────────┴─────────┐
                     │                  │
                 NO  ▼                  ▼ YES
              ┌──────────────┐   ┌──────────────┐
              │  PROCESS:    │   │  PROCESS:    │
              │  Set Flash   │   │  Verify      │
              │  "Invalid    │   │  Password    │
              │   Creds"     │   │  Hash        │
              └──────┬───────┘   └──────┬───────┘
                     │                  │
                     │                  ▼
                     |                  / \
                     │                 /   \
                     │                /     \
                     │               / Valid?\
                     │               \       /
                     │                \     /
                     │                 \   /
                     │                  \/
                     │                  │
                     │                  │
                     │         ┌────────┴────────┐
                     │         │                 │
                     │     NO  ▼                 ▼ YES
                     │   ┌──────────┐   ┌───────────────┐
                     │   │ PROCESS: │   │  PROCESS:     │
                     │   │ Set Flash│   │  Regenerate   │
                     │   │ Error    │   │  Session ID   │
                     │   └────┬─────┘   └───────┬───────┘
                     │        │                  │
                     │        │                  ▼
                     │        │         ┌────────────────┐
                     │        │         │  PROCESS:      │
                     │        │         │  Set Session   │
                     │        │         │  Variables:    │
                     │        │         │  - user_id     │
                     │        │         │  - user_email  │
                     │        │         │  - user_role   │
                     │        │         │  - role_id     │
                     │        │         │  - idle_time   │
                     │        │         │  - last_active │
                     │        │         └────────┬───────┘
                     │        │                  │
                     │        │                  ▼
                     |        |                  /\ 
                     |        |                 /  \
                     |        |                /    \
                     │        │               /      \
                     │        │              /        \
                     │        │             / Checked? \
                     │        │             \          /
                     │        │              \        /
                     │        │               \      /
                     │        │                \    /
                     |        |                 \  /
                     |        |                  \/
                     │        │                  │
                     │        │                  │
                     │        │         ┌────────┴───────┐
                     │        │         │                │
                     │        │     YES ▼                ▼ NO
                     │        │   ┌──────────┐   ┌──────────┐
                     │        │   │ PROCESS: │   │ PROCESS: │
                     │        │   │ Generate │   │ Skip     │
                     │        │   │ Token &  │   │ Token    │
                     │        │   │ Store in │   │          │
                     │        │   │ Database │   │          │
                     │        │   │ Set      │   │          │
                     │        │   │ Cookie   │   │          │
                     │        │   └────┬─────┘   └────┬─────┘
                     │        │        │              │
                     │        │        └──────┬───────┘
                     │        │               │
                     │        │               ▼
                     │        │      ┌────────────────┐
                     │        │      │  PROCESS:      │
                     │        │      │  UPDATE users  │
                     │        │      │  SET last_login│
                     │        │      │  = NOW()       │
                     │        │      └────────┬───────┘
                     │        │               │
                     └────────┴───────────────┘
                              │
                              ▼
                     ╔════════════════╗
                     ║  OUTPUT:       ║
                     ║  Redirect to   ║
                     ║  Dashboard OR  ║
                     ║  Login Page    ║
                     ╚════════╤═══════╝
                              │
                              ▼
                     ╭────────────────╮
                     │      END       │
                     ╰────────────────╯
```

### 4. Session Lock/Unlock Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    SESSION LOCK FLOW                         │
└─────────────────────────────────────────────────────────────┘

        ╭─────────────────╮
        │  START:         │
        │  User is        │
        │  Authenticated  │
        │  in Dashboard   │
        ╰────────┬────────╯
                 │
                 ▼
        ╔═════════════════╗
        ║  INPUT:         ║
        ║  User Clicks    ║
        ║  "Lock Session" ║
        ║  in Header      ║
        ╚════════╤════════╝
                 │
                 ▼
        ╔═════════════════╗
        ║  OUTPUT:        ║
        ║  POST to        ║
        ║  lock-session   ║
        ║  .php           ║
        ╚════════╤════════╝
                 │
                 ▼
        ┌─────────────────┐
        │  PROCESS:       │
        │  Validate       │
        │  Active Session │
        │  Exists         │
        └────────┬────────┘
                 │
                 ▼
                / \
               /   \
              /     \
             /       \
            / Exists? \
            \         /
             \       /
              \     /
               \   /
                \ /
                 V
                 │
        ┌────────┴────────┐
        │                 │
    NO  ▼                 ▼ YES
╔══════════════╗   ┌──────────────────┐
║  OUTPUT:     ║   │  PROCESS:        │
║  Redirect to ║   │  Store in        │
║  login.php   ║   │  Session:        │
╚══════════════╝   │  locked_user_id  │
                   │  locked_email    │
                   │  locked_role     │
                   │  session_locked  │
                   │  = true          │
                   └────────┬─────────┘
                            │
                            ▼
                   ┌─────────────────┐
                   │  PROCESS:       │
                   │  Clear Active   │
                   │  Session Vars:  │
                   │  user_id        │
                   │  user_email     │
                   │  user_role      │
                   │  last_activity  │
                   └────────┬────────┘
                            │
                            ▼
                   ┌─────────────────┐
                   │  PROCESS:       │
                   │  Regenerate     │
                   │  Session ID     │
                   └────────┬────────┘
                            │
                            ▼
                   ╔═════════════════╗
                   ║  OUTPUT:        ║
                   ║  Redirect to    ║
                   ║  lockscreen.php ║
                   ╚════════╤════════╝
                            │
                            ▼
                   ╭─────────────────╮
                   │      END        │
                   ╰─────────────────╯

┌─────────────────────────────────────────────────────────────┐
│                   SESSION UNLOCK FLOW                        │
└─────────────────────────────────────────────────────────────┘

        ╭─────────────────╮
        │  START:         │
        │  Lockscreen     │
        │  Page Displays  │
        ╰────────┬────────╯
                 │
                 ▼
        ╔═════════════════╗
        ║  OUTPUT:        ║
        ║  Display Form   ║
        ║  - User Email   ║
        ║  - Pass Field   ║
        ╚════════╤════════╝
                 │
                 ▼
        ╔═════════════════╗
        ║  INPUT:         ║
        ║  User Enters    ║
        ║  Password       ║
        ╚════════╤════════╝
                 │
                 ▼
        ╔═════════════════╗
        ║  OUTPUT:        ║
        ║  POST to        ║
        ║  lockscreen.php ║
        ╚════════╤════════╝
                 │
                 ▼
        ┌─────────────────┐
        │  PROCESS:       │
        │  Check Locked   │
        │  Session Exists │
        └────────┬────────┘
                 │
                 ▼
                / \
               /   \
              /     \
             /       \
            / Exists? \
            \         /
             \       /
              \     /
               \   /
                \ /
                 V
                 │
        ┌────────┴────────┐
        │                 │
    NO  ▼                 ▼ YES
╔═══════════════╗   ┌─────────────────┐
║  OUTPUT:      ║   │  PROCESS:       │
║  Set Flash    ║   │  Get locked_    │
║  Error        ║   │  user_id        │
║  Redirect to  ║   └────────┬────────┘
║  login.php    ║            │
╚═══════════════╝            ▼
                   ┌─────────────────┐
                   │  PROCESS:       │
                   │  Query Database │
                   │  for User Pass  │
                   │  Hash           │
                   └────────┬────────┘
                            │
                            ▼
                   ┌─────────────────┐
                   │  PROCESS:       │
                   │  Verify         │
                   │  Password       │
                   │  password_      │
                   │  verify()       │
                   └────────┬────────┘
                            │
                            ▼
                            /\
                           /  \
                          /    \
                         /      \
                        / Valid? \
                        \        /
                         \      /
                          \    /
                           \  /
                            \/
                            │
                            │
                   ┌────────┴────────┐
                   │                 │
               NO  ▼                 ▼ YES
         ┌────────────────┐   ┌────────────────┐
         │  PROCESS:      │   │  PROCESS:      │
         │  Set Flash     │   │  Restore       │
         │  "Invalid      │   │  Session Vars: │
         │   Password"    │   │  user_id       │
         │  Stay on       │   │  user_email    │
         │  Lockscreen    │   │  user_role     │
         └────────────────┘   │  last_activity │
                              └────────┬───────┘
                                       │
                                       ▼
                              ┌────────────────┐
                              │  PROCESS:      │
                              │  Clear Locked  │
                              │  Session Vars  │
                              └────────┬───────┘
                                       │
                                       ▼
                              ┌────────────────┐
                              │  PROCESS:      │
                              │  Regenerate    │
                              │  Session ID    │
                              └────────┬───────┘
                                       │
                                       ▼
                              ┌────────────────┐
                              │  PROCESS:      │
                              │  Set Flash     │
                              │  "Unlocked"    │
                              └────────┬───────┘
                                       │
                                       ▼
                              ╔════════════════╗
                              ║  OUTPUT:       ║
                              ║  Redirect to   ║
                              ║  Dashboard     ║
                              ╚════════╤═══════╝
                                       │
                                       ▼
                              ╭────────────────╮
                              │      END       │
                              ╰────────────────╯
```

### 5. Idle Timeout Monitoring Flow

```
┌─────────────────────────────────────────────────────────────┐
│              CLIENT-SIDE (JavaScript)                        │
└─────────────────────────────────────────────────────────────┘

        ╭─────────────────╮
        │  START:         │
        │  Page Load      │
        │  Dashboard      │
        ╰────────┬────────╯
                 │
                 ▼
        ┌─────────────────┐
        │  PROCESS:       │
        │  Get User Idle  │
        │  Timeout from   │
        │  Session        │
        │  (in minutes)   │
        └────────┬────────┘
                 │
                 ▼
        ┌─────────────────┐
        │  PROCESS:       │
        │  Initialize     │
        │  - lastActivity │
        │  - warningTime  │
        │  - timeoutTime  │
        └────────┬────────┘
                 │
                 ▼
        ┌─────────────────┐
        │  PROCESS:       │
        │  Register Event │
        │  Listeners:     │
        │  - mousemove    │
        │  - keypress     │
        │  - click        │
        │  - scroll       │
        │  - touchstart   │
        └────────┬────────┘
                 │
         ┌───────┴────────┐
         │                │
         ▼                ▼
╔═══════════════╗   ┌──────────────┐
║  INPUT:       ║   │  PROCESS:    │
║  Activity     ║   │  Monitor     │
║  Detected     ║   │  Timer       │
║               ║   │  (every 10s) │
╚═══════╤═══════╝   └──────┬───────┘
        │                  │
        ▼                  ▼
┌─────────────┐   ┌──────────────┐
│  PROCESS:   │   │  PROCESS:    │
│  Update     │   │  Calculate   │
│  lastActivity│  │  Elapsed     │
└─────────────┘   │  Time        │
                  └──────┬───────┘
                         │
                         ▼
                  ┌──────────────┐
                  │  PROCESS:    │
                  │  Check Time  │
                  └──────┬───────┘
                         │
                         ▼
                         / \
                        /   \
                       /     \
                      /       \
                     / Status? \
                     \         /
                      \       /
                       \     /
                        \   /
                         \ /
                          V
                          │
          ┌──────────────┼──────────────┐
          │              │              │
          ▼              ▼              ▼
  ┌─────────────┐ ╔══════════════╗ ╔══════════════╗
  │  PROCESS:   │ ║  OUTPUT:     ║ ║  OUTPUT:     ║
  │  < Warning  │ ║  Show        ║ ║  POST to     ║
  │  Time       │ ║  Warning     ║ ║  lock-       ║
  │             │ ║  Toast:      ║ ║  session.php ║
  │  Continue   │ ║  "Session    ║ ║              ║
  │  Monitoring │ ║  locking in  ║ ║  Redirect    ║
  └─────────────┘ ║  2 mins"     ║ ║  lockscreen  ║
                  ╚══════╤═══════╝ ╚══════════════╝
                         │
                         ▼
                        / \
                       /   \
                      /     \
                     /  Stay \
                     \ Active?/
                      \      /
                       \    /
                        \  /
                         \/
                         │
              ┌──────────┴──────────┐
              │                     │
          YES ▼                     ▼ NO
      ┌──────────────┐   ┌──────────────┐
      │  PROCESS:    │   │  PROCESS:    │
      │  Dismiss     │   │  Continue    │
      │  Warning     │   │  Timer       │
      │  Reset Timer │   │              │
      └──────────────┘   └──────────────┘

┌─────────────────────────────────────────────────────────────┐
│              SERVER-SIDE (PHP)                               │
└─────────────────────────────────────────────────────────────┘

        ╔═════════════════╗
        ║  INPUT:         ║
        ║  AJAX Request   ║
        ║  update-activity║
        ║  .php           ║
        ║  (every 60s)    ║
        ╚════════╤════════╝
                 │
                 ▼
        ┌─────────────────┐
        │  PROCESS:       │
        │  Update Session │
        │  last_activity  │
        │  = NOW()        │
        └────────┬────────┘
                 │
                 ▼
        ╔═════════════════╗
        ║  OUTPUT:        ║
        ║  Return Success ║
        ║  JSON Response  ║
        ╚═════════════════╝

        ╔═════════════════╗
        ║  INPUT:         ║
        ║  Page Request   ║
        ║  (Protected)    ║
        ╚════════╤════════╝
                 │
                 ▼
        ┌─────────────────┐
        │  PROCESS:       │
        │  Check Session  │
        │  Timeout        │
        └────────┬────────┘
                 │
                 ▼
        ┌─────────────────┐
        │  PROCESS:       │
        │  Calculate:     │
        │  idle_duration  │
        │  = current_time │
        │  - last_activity│
        └────────┬────────┘
                 │
                 ▼
                 /\
                /  \
               /    \
              /      \
             /        \
             \ Timeout?/
              \       /
               \     /
                \   /
                 \/
                 │
        ┌────────┴────────┐
        │                 │
    YES ▼                 ▼ NO
╔══════════════╗   ┌──────────────┐
║  OUTPUT:     ║   │  PROCESS:    │
║  Auto-Lock   ║   │  Allow Access│
║  Session     ║   │  Update      │
║              ║   │  last_activity│
║  Set Flash   ║   └──────────────┘
║  "Session    ║
║   Timed Out" ║
║              ║
║  Redirect    ║
║  lockscreen  ║
╚══════════════╝
```

### 6. Remember Me Token Flow

```
┌─────────────────────────────────────────────────────────────┐
│                  TOKEN GENERATION                            │
└─────────────────────────────────────────────────────────────┘

        ╭─────────────────╮
        │  START:         │
        │  User Logs In   │
        │  with "Remember │
        │  Me" Checked    │
        ╰────────┬────────╯
                 │
                 ▼
        ┌─────────────────┐
        │  PROCESS:       │
        │  Generate       │
        │  Random Bytes   │
        │  selector(8)    │
        │  validator(32)  │
        └────────┬────────┘
                 │
                 ▼
        ┌─────────────────┐
        │  PROCESS:       │
        │  Hash Validator │
        │  (Bcrypt)       │
        └────────┬────────┘
                 │
                 ▼
        ┌─────────────────┐
        │  PROCESS:       │
        │  INSERT INTO    │
        │  remember_tokens│
        │  - user_id      │
        │  - selector     │
        │  - hashed_val   │
        │  - expires_at   │
        │    (30 days)    │
        └────────┬────────┘
                 │
                 ▼
        ╔═════════════════╗
        ║  OUTPUT:        ║
        ║  Set Cookie     ║
        ║  selector:      ║
        ║  validator      ║
        ║  (30 days)      ║
        ║  HttpOnly       ║
        ║  Secure         ║
        ║  SameSite=Lax   ║
        ╚════════╤════════╝
                 │
                 ▼
        ╭─────────────────╮
        │      END        │
        ╰─────────────────╯

┌─────────────────────────────────────────────────────────────┐
│                  TOKEN VALIDATION                            │
└─────────────────────────────────────────────────────────────┘

        ╭─────────────────╮
        │  START:         │
        │  User Visits    │
        │  Protected Page │
        │  (No Session)   │
        ╰────────┬────────╯
                 │
                 ▼
        ┌─────────────────┐
        │  PROCESS:       │
        │  Check for      │
        │  remember_token │
        │  Cookie         │
        └────────┬────────┘
                 │
                 ▼
                / \
               /   \
              /     \
             /       \
            / Exists? \
            \         /
             \       /
              \     /
               \   /
                \ /
                 V
                 │
        ┌────────┴────────┐
        │                 │
    NO  ▼                 ▼ YES
╔══════════════╗   ┌──────────────┐
║  OUTPUT:     ║   │  PROCESS:    │
║  Redirect to ║   │  Parse Cookie│
║  login.php   ║   │  Split by :  │
╚══════════════╝   │  selector    │
                   │  validator   │
                   └──────┬───────┘
                          │
                          ▼
                   ┌──────────────┐
                   │  PROCESS:    │
                   │  Query Token │
                   │  from DB     │
                   │  WHERE       │
                   │  selector =  │
                   │  AND expires │
                   │  > NOW()     │
                   └─────┬────────┘
                         │
                         ▼
                        /\
                       /  \
                      /    \
                     /      \
                    / Found? \
                    \        /
                     \      /
                      \    /
                       \  /
                        \/
                        │
                        │
               ┌────────┴────────┐
               │                 │
           NO  ▼                 ▼ YES
      ╔══════════════╗   ┌─────────────────┐
      ║  OUTPUT:     ║   │  PROCESS:       │
      ║  Delete      ║   │  Verify         │
      ║  Cookie      ║   │  Validator Hash │
      ║  Redirect to ║   │  password_      │
      ║  login.php   ║   │  verify()       │
      ╚══════════════╝   └────────┬────────┘
                              │
                              ▼
                              / \
                             /   \
                            /     \
                           / Valid?\
                           \       /
                            \     /
                             \   /
                              \/
                              │
                     ┌────────┴────────┐
                     │                 │
                 NO  ▼                 ▼ YES
             ╔═══════════╗     ┌────────────────┐
             ║  OUTPUT:  ║     │  PROCESS:      │
             ║  Delete   ║     │  Get user_id   │
             ║  Token &  ║     │  from Token    │
             ║  Cookie   ║     └────────┬───────┘
             ║  Redirect ║              │
             ║  to login ║              ▼
             ╚═══════════╝     ┌────────────────┐
                              │  PROCESS:      │
                              │  Query User    │
                              │  Details       │
                              └────────┬───────┘
                                       │
                                       ▼
                              ┌────────────────┐
                              │  PROCESS:      │
                              │  Create New    │
                              │  Session       │
                              │  Auto-Login    │
                              │  User          │
                              └────────┬───────┘
                                       │
                                       ▼
                              ┌────────────────┐
                              │  PROCESS:      │
                              │  Generate New  │
                              │  Remember Token│
                              │  (Rotate)      │
                              └────────┬───────┘
                                       │
                                       ▼
                              ┌────────────────┐
                              │  PROCESS:      │
                              │  Delete Old    │
                              │  Token         │
                              └────────┬───────┘
                                       │
                                       ▼
                              ╔════════════════╗
                              ║  OUTPUT:       ║
                              ║  Allow Access  ║
                              ║  to Page       ║
                              ╚════════╤═══════╝
                                       │
                                       ▼
                              ╭────────────────╮
                              │      END       │
                              ╰────────────────╯
```

### 7. Role-Based Access Control Flow

```
        ╭─────────────────╮
        │  START:         │
        │  User Requests  │
        │  Protected Page │
        ╰────────┬────────╯
                 │
                 ▼
        ┌─────────────────┐
        │  PROCESS:       │
        │  INCLUDE        │
        │  access.php     │
        └────────┬────────┘
                 │
                 ▼
        ┌─────────────────┐
        │  PROCESS:       │
        │  Check Session  │
        │  isset(user_id) │
        └────────┬────────┘
                 │
                 ▼
                 /\
                /  \
               /    \
              / Auth? \
              \       /
               \     /
                \   /
                 \ /
                  v
                 |
        ┌────────┴────────┐
        │                 │
    NO  ▼                 ▼ YES
┌──────────────┐   ┌──────────────────┐
│  PROCESS:    │   │  PROCESS:        │
│  Check       │   │  Get User Role   │
│  Remember    │   │  from Session    │
│  Token       │   └────────┬─────────┘
└──────┬───────┘            │
       │                    ▼
       ▼             ┌──────────────────┐
      /\             │  PROCESS:        │
     /  \            │  Check Role      │
    /    \           │  Hierarchy:      │
   / Token\          │  admin(5)        │
   \ Valid?/         │  doctor(4)       │
    \     /          │  nurse(3)        │
     \   /           │  staff(2)        │
      \ /            │  patient(1)      │
       v             └────────┬─────────┘
       │                      │
    ┌──┴───┐                  │
    │      │                  │
YES ▼      ▼ NO               │
┌─────────┐ ╔═══════════╗    ▼
│PROCESS: │ ║  OUTPUT:  ║   /\
│Auto     │ ║  Redirect ║  /  \
│Login    │ ║  to login ║ /    \
│User     │ ╚═══════════╝/  Role \
└────┬────┘            \ Enough? /
     │                  \       /
     │                   \     /
     │                    \   /
     │                     \ /
     │                      V
     │                      │
     └──────────────────────┘
                 │
        ┌────────┴────────┐
        │                 │
    NO  ▼                 ▼ YES
╔═══════════════╗   ╔═══════════════╗
║  OUTPUT:      ║   ║  OUTPUT:      ║
║  Set Flash    ║   ║  Allow Page   ║
║  "Access      ║   ║  Access       ║
║   Denied"     ║   ╚═══════╤═══════╝
║               ║           │
║  Redirect to  ║           ▼
║  Dashboard    ║   ╭───────────────╮
╚═══════════════╝   │      END      │
                    ╰───────────────╯

┌─────────────────────────────────────────────────────────────┐
│              ROLE PERMISSION MATRIX                          │
└─────────────────────────────────────────────────────────────┘

Page/Feature          │Admin│Doctor│Nurse│Staff│Patient│
──────────────────────┼─────┼──────┼─────┼─────┼───────┤
Dashboard             │  ✓  │  ✓   │  ✓  │  ✓  │   ✓   │
User Management       │  ✓  │  ✗   │  ✗  │  ✗  │   ✗   │
Patient Records       │  ✗  │  ✓   │  ✓  │  ✗  │   ✓   │
Own Profile View      │  ✓  │  ✓   │  ✓  │  ✓  │   ✓   │
System Settings       │  ✓  │  ✗   │  ✗  │  ✗  │   ✗   │
Audit Logs            │  ✓  │  ✗   │  ✗  │  ✗  │   ✗   │
Appointments (Create) │  ✓  │  ✓   │  ✓  │  ✓  │   ✓   │
Prescriptions (Write) │  ✗  │  ✓   │  ✗  │  ✗  │   ✗   │
Reports (Generate)    │  ✓  │  ✓   │  ✓  │  ✗  │   ✗   │
```

### 8. Complete Authentication Lifecycle

```
┌─────────────────────────────────────────────────────────────────────┐
│                   AUTHENTICATION LIFECYCLE                          │
└─────────────────────────────────────────────────────────────────────┘

                        ┌─────────────┐
                        │   GUEST     │
                        │   STATE     │
                        └──────┬──────┘
                               │
                   ┌───────────┴───────────┐
                   │                       │
                   ▼                       ▼
          ┌────────────────┐      ┌────────────────┐
          │   REGISTER     │      │   LOGIN        │
          │   - New User   │      │   - Existing   │
          └────────┬───────┘      └────────┬───────┘
                   │                       │
                   │                       │
                   └───────────┬───────────┘
                               │
                               ▼
                      ┌────────────────┐
                      │ AUTHENTICATED  │
                      │ STATE          │
                      │ - Session      │
                      │   Created      │
                      │ - User ID Set  │
                      │ - Role Loaded  │
                      └────────┬───────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                │
              ▼                ▼                ▼
     ┌────────────┐   ┌────────────┐   ┌────────────┐
     │  ACTIVE    │   │  IDLE      │   │  MANUAL    │
     │  Using App │   │  Timeout   │   │  Lock      │
     └──────┬─────┘   └──────┬─────┘   └──────┬─────┘
            │                │                │
            │                └────────┬───────┘
            │                         │
            │                         ▼
            │                ┌────────────────┐
            │                │  LOCKED        │
            │                │  STATE         │
            │                │  - Session     │
            │                │    Locked      │
            │                │  - Require     │
            │                │    Password    │
            │                └────────┬───────┘
            │                         │
            │                ┌────────┴────────┐
            │                │                 │
            │          UNLOCK▼                 ▼TIMEOUT
            │       ┌──────────────┐   ┌──────────────┐
            │       │  Verify Pass │   │  Force       │
            │       │  Restore     │   │  Logout      │
            │       │  Session     │   └──────┬───────┘
            │       └──────┬───────┘          │
            │              │                  │
            └──────────────┴──────────────────┘
                           │
                           ▼
                  ┌────────────────┐
                  │   LOGOUT       │
                  │   - Session    │
                  │     Destroyed  │
                  │   - Tokens     │
                  │     Cleared    │
                  │   - Cookies    │
                  │     Deleted    │
                  └────────┬───────┘
                           │
                           ▼
                  ┌────────────────┐
                  │   GUEST        │
                  │   STATE        │
                  └────────────────┘
```

---

## Data Flow Procedures

### 1. Request Processing Flow

```
PROCEDURE: Process_HTTP_Request
BEGIN
  1. Client sends HTTP request
  2. Web server (Apache/Nginx) receives request
  3. Route to appropriate PHP script
  4. Initialize session configuration
     CALL Load_Session_Config()
  5. Establish database connection
     CALL Get_Database_Connection()
  6. Process authentication requirements
     IF protected_page THEN
        CALL Require_Authentication()
     END IF
  7. Execute business logic
  8. Generate response (HTML/JSON/Redirect)
  9. Send response to client
  10. Close database connection
  11. Write session data
END PROCEDURE
```

### 2. Database Connection Flow

```
PROCEDURE: Get_Database_Connection
INPUT: None
OUTPUT: PDO Connection Object
BEGIN
  1. Check if static connection exists
     IF connection_exists THEN
        RETURN existing_connection
     END IF
  
  2. Build DSN string
     dsn = "mysql:host=DB_HOST;port=DB_PORT;dbname=DB_NAME;charset=DB_CHARSET"
  
  3. Set PDO options
     options = [
        ERRMODE => EXCEPTION,
        DEFAULT_FETCH_MODE => ASSOC,
        EMULATE_PREPARES => false
     ]
  
  4. Attempt connection
     TRY
        pdo = new PDO(dsn, DB_USER, DB_PASS, options)
        STORE pdo in static variable
        RETURN pdo
     CATCH PDOException
        LOG error message
        THROW user-friendly exception
     END TRY
END PROCEDURE
```

---

## Authentication Procedures

### 1. User Registration Procedure

```
PROCEDURE: Register_User
INPUT: email, password, confirm_password, full_name, role_id (optional, default=5)
OUTPUT: success_status, message, redirect_url
BEGIN
  -- CLIENT-SIDE VALIDATION (JavaScript)
  1. Validate email format using regex
  2. Check password length >= 8 characters
  3. Check password confirmation matches
  4. Display real-time validation feedback
  5. IF validation_fails THEN
        SHOW error message
        PREVENT form submission
        EXIT
     END IF
  
  -- FORM SUBMISSION
  6. Submit form via POST to register.php
  
  -- SERVER-SIDE VALIDATION
  7. Sanitize inputs
     email = trim(email)
     password = trim(password)
     full_name = trim(full_name)
  
  8. Validate email format
     IF NOT valid_email(email) THEN
        SET flash_message = "Invalid email format"
        REDIRECT back to form
        EXIT
     END IF
  
  9. Validate password strength
     IF length(password) < 8 THEN
        SET flash_message = "Password must be at least 8 characters"
        REDIRECT back to form
        EXIT
     END IF
  
  10. Validate passwords match
      IF password != confirm_password THEN
         SET flash_message = "Passwords do not match"
         REDIRECT back to form
         EXIT
      END IF
  
  -- DATABASE OPERATIONS
  11. Check email uniqueness
      EXECUTE QUERY: "SELECT id FROM users WHERE email = ?"
      IF record_exists THEN
         SET flash_message = "Email already registered"
         REDIRECT back to form
         EXIT
      END IF
  
  12. Validate role_id exists
      EXECUTE QUERY: "SELECT id FROM roles WHERE id = ?"
      IF NOT exists THEN
         role_id = 5  -- Default to patient
      END IF
  
  13. Hash password using bcrypt
      hashed_password = password_hash(password, BCRYPT, cost=12)
  
  14. Insert new user record
      EXECUTE QUERY: 
         "INSERT INTO users (email, password, role_id, full_name) 
          VALUES (?, ?, ?, ?)"
      WITH PARAMETERS: [email, hashed_password, role_id, full_name]
  
  15. IF insert_successful THEN
         SET flash_message = "Registration successful! Please login."
         REDIRECT to login.php
      ELSE
         SET flash_message = "Registration failed. Please try again."
         REDIRECT back to form
      END IF
END PROCEDURE
```

### 2. User Login Procedure

```
PROCEDURE: Login_User
INPUT: email, password, remember_me (optional)
OUTPUT: success_status, redirect_url
BEGIN
  -- CLIENT-SIDE VALIDATION
  1. Validate email is not empty
  2. Validate password is not empty
  3. Display validation feedback
  
  -- FORM SUBMISSION
  4. Submit form via POST to login.php
  
  -- SERVER-SIDE VALIDATION
  5. Sanitize inputs
     email = trim(email)
     password = trim(password)
  
  6. Validate email format
     IF NOT valid_email(email) THEN
        SET flash_message = "Invalid email format"
        REDIRECT back to login
        EXIT
     END IF
  
  -- AUTHENTICATION
  7. Query user by email with role information
     EXECUTE QUERY:
        "SELECT u.id, u.email, u.password, u.role_id, r.name as role_name,
                r.idle_time
         FROM users u
         LEFT JOIN roles r ON u.role_id = r.id
         WHERE u.email = ?"
     WITH PARAMETERS: [email]
  
  8. IF user_not_found THEN
        SET flash_message = "Invalid email or password"
        REDIRECT back to login
        EXIT
     END IF
  
  9. Verify password hash
     IF NOT password_verify(password, user.password) THEN
        SET flash_message = "Invalid email or password"
        REDIRECT back to login
        EXIT
     END IF
  
  -- SESSION CREATION
  10. Regenerate session ID for security
      session_regenerate_id(delete_old_session=true)
  
  11. Set session variables
      $_SESSION['user_id'] = user.id
      $_SESSION['user_email'] = user.email
      $_SESSION['user_role'] = user.role_name
      $_SESSION['role_id'] = user.role_id
      $_SESSION['idle_time'] = user.idle_time
      $_SESSION['last_activity'] = current_timestamp
      $_SESSION['login_time'] = current_timestamp
  
  -- REMEMBER ME FUNCTIONALITY
  12. IF remember_me_checked THEN
         CALL Create_Remember_Token(user.id)
      END IF
  
  -- UPDATE USER RECORD
  13. Update last login timestamp
      EXECUTE QUERY:
         "UPDATE users SET last_login = NOW() WHERE id = ?"
      WITH PARAMETERS: [user.id]
  
  -- REDIRECT
  14. SET flash_message = "Login successful!"
  15. REDIRECT to dashboard.php
END PROCEDURE
```

### 3. Remember Me Token Procedure

```
PROCEDURE: Create_Remember_Token
INPUT: user_id
OUTPUT: token_cookie
BEGIN
  1. Generate secure random token
     selector = bin2hex(random_bytes(8))
     validator = bin2hex(random_bytes(32))
  
  2. Hash validator for storage
     hashed_validator = password_hash(validator, BCRYPT)
  
  3. Calculate expiry (30 days from now)
     expiry = current_timestamp + (30 * 24 * 60 * 60)
  
  4. Store token in database
     EXECUTE QUERY:
        "INSERT INTO remember_tokens 
         (user_id, selector, hashed_validator, expires_at)
         VALUES (?, ?, ?, ?)"
     WITH PARAMETERS: [user_id, selector, hashed_validator, expiry]
  
  5. Create cookie value
     cookie_value = selector + ":" + validator
  
  6. Set secure cookie
     setcookie(
        name = "remember_token",
        value = cookie_value,
        expires = expiry,
        path = "/",
        secure = true,
        httponly = true,
        samesite = "Lax"
     )
END PROCEDURE
```

### 4. Validate Remember Me Token Procedure

```
PROCEDURE: Validate_Remember_Token
INPUT: None (reads from cookie)
OUTPUT: user_id or null
BEGIN
  1. Check if remember_token cookie exists
     IF NOT cookie_exists THEN
        RETURN null
     END IF
  
  2. Parse cookie value
     TRY
        parts = split(cookie_value, ":")
        selector = parts[0]
        validator = parts[1]
     CATCH
        RETURN null
     END TRY
  
  3. Query token from database
     EXECUTE QUERY:
        "SELECT user_id, hashed_validator, expires_at
         FROM remember_tokens
         WHERE selector = ? AND expires_at > NOW()"
     WITH PARAMETERS: [selector]
  
  4. IF token_not_found THEN
        CALL Delete_Cookie("remember_token")
        RETURN null
     END IF
  
  5. Verify validator hash
     IF NOT password_verify(validator, token.hashed_validator) THEN
        CALL Delete_Token(selector)
        CALL Delete_Cookie("remember_token")
        RETURN null
     END IF
  
  6. Token is valid
     RETURN token.user_id
END PROCEDURE
```

### 5. Session Lock Procedure

```
PROCEDURE: Lock_Session
INPUT: None (uses current session)
OUTPUT: redirect_url
BEGIN
  1. Validate active session exists
     IF NOT isset($_SESSION['user_id']) THEN
        REDIRECT to login.php
        EXIT
     END IF
  
  2. Store user data in locked state
     $_SESSION['locked_user_id'] = $_SESSION['user_id']
     $_SESSION['locked_user_email'] = $_SESSION['user_email']
     $_SESSION['locked_user_role'] = $_SESSION['user_role']
     $_SESSION['session_locked'] = true
     $_SESSION['lock_time'] = current_timestamp
  
  3. Clear active session variables
     UNSET $_SESSION['user_id']
     UNSET $_SESSION['user_email']
     UNSET $_SESSION['user_role']
     UNSET $_SESSION['last_activity']
  
  4. Regenerate session ID
     session_regenerate_id(delete_old_session=true)
  
  5. REDIRECT to lockscreen.php
END PROCEDURE
```

### 6. Session Unlock Procedure

```
PROCEDURE: Unlock_Session
INPUT: password
OUTPUT: success_status, redirect_url
BEGIN
  1. Validate locked session exists
     IF NOT isset($_SESSION['locked_user_id']) THEN
        SET flash_message = "No locked session found"
        REDIRECT to login.php
        EXIT
     END IF
  
  2. Retrieve user data
     user_id = $_SESSION['locked_user_id']
     user_email = $_SESSION['locked_user_email']
  
  3. Query user password hash
     EXECUTE QUERY:
        "SELECT password FROM users WHERE id = ?"
     WITH PARAMETERS: [user_id]
  
  4. Verify password
     IF NOT password_verify(password, user.password) THEN
        SET flash_message = "Invalid password"
        REDIRECT back to lockscreen
        EXIT
     END IF
  
  5. Restore session variables
     $_SESSION['user_id'] = $_SESSION['locked_user_id']
     $_SESSION['user_email'] = $_SESSION['locked_user_email']
     $_SESSION['user_role'] = $_SESSION['locked_user_role']
     $_SESSION['last_activity'] = current_timestamp
  
  6. Clear locked session variables
     UNSET $_SESSION['locked_user_id']
     UNSET $_SESSION['locked_user_email']
     UNSET $_SESSION['locked_user_role']
     UNSET $_SESSION['session_locked']
     UNSET $_SESSION['lock_time']
  
  7. Regenerate session ID
     session_regenerate_id(delete_old_session=true)
  
  8. SET flash_message = "Session unlocked successfully"
  9. REDIRECT to dashboard.php
END PROCEDURE
```

### 7. Logout Procedure

```
PROCEDURE: Logout_User
INPUT: None (uses current session)
OUTPUT: redirect_url
BEGIN
  1. Delete remember me token if exists
     IF cookie_exists("remember_token") THEN
        CALL Delete_Remember_Token_By_Cookie()
     END IF
  
  2. Clear all session variables
     $_SESSION = array()
  
  3. Delete session cookie
     IF cookie_params_exist THEN
        setcookie(
           session_name(),
           "",
           expires = time() - 3600,
           path = cookie_params.path,
           domain = cookie_params.domain,
           secure = cookie_params.secure,
           httponly = true
        )
     END IF
  
  4. Destroy session
     session_destroy()
  
  5. Delete remember me cookie
     setcookie("remember_token", "", time() - 3600, "/")
  
  6. SET flash_message = "You have been logged out successfully"
  7. REDIRECT to login.php
END PROCEDURE
```

---

## Authorization Procedures

### 1. Role-Based Access Control (RBAC) Check

```
PROCEDURE: Check_User_Permission
INPUT: required_role or required_permission
OUTPUT: boolean (has_permission)
BEGIN
  1. Validate user is authenticated
     IF NOT isset($_SESSION['user_id']) THEN
        RETURN false
     END IF
  
  2. Get user's role
     user_role = $_SESSION['user_role']
     role_id = $_SESSION['role_id']
  
  3. Define role hierarchy
     role_levels = {
        'admin': 5,
        'doctor': 4,
        'nurse': 3,
        'staff': 2,
        'patient': 1
     }
  
  4. Check if user has required role
     IF role_levels[user_role] >= role_levels[required_role] THEN
        RETURN true
     ELSE
        RETURN false
     END IF
END PROCEDURE
```

### 2. Require Authentication Middleware

```
PROCEDURE: Require_Authentication
INPUT: None
OUTPUT: void or redirect
BEGIN
  1. Check if session is active
     IF NOT isset($_SESSION['user_id']) THEN
        -- Check remember me token
        user_id = CALL Validate_Remember_Token()
        
        IF user_id IS NOT NULL THEN
           -- Auto-login via remember me
           CALL Auto_Login_From_Token(user_id)
           RETURN
        END IF
        
        -- No valid session or token
        SET flash_message = "Please login to continue"
        REDIRECT to login.php
        EXIT
     END IF
  
  2. Check session validity
     CALL Validate_Session_Timeout()
  
  3. Update last activity timestamp
     $_SESSION['last_activity'] = current_timestamp
END PROCEDURE
```

### 3. Require Guest Middleware

```
PROCEDURE: Require_Guest
INPUT: None
OUTPUT: void or redirect
BEGIN
  1. Check if user is already logged in
     IF isset($_SESSION['user_id']) THEN
        REDIRECT to dashboard.php
        EXIT
     END IF
  
  2. Check if session is locked
     IF isset($_SESSION['session_locked']) THEN
        REDIRECT to lockscreen.php
        EXIT
     END IF
  
  3. Allow access to page
     RETURN
END PROCEDURE
```

### 4. Role-Specific Page Access

```
PROCEDURE: Require_Role
INPUT: required_roles (array)
OUTPUT: void or redirect
BEGIN
  1. Ensure user is authenticated
     CALL Require_Authentication()
  
  2. Get user's role
     user_role = $_SESSION['user_role']
  
  3. Check if user has required role
     IF user_role NOT IN required_roles THEN
        SET flash_message = "Access denied: Insufficient permissions"
        REDIRECT to dashboard.php
        EXIT
     END IF
  
  4. Allow access to page
     RETURN
END PROCEDURE
```

---

## Session Management Procedures

### 1. Session Initialization

```
PROCEDURE: Initialize_Session
INPUT: None
OUTPUT: void
BEGIN
  1. Set session cookie parameters
     session_set_cookie_params([
        'lifetime' => 0,  -- Session cookie (until browser close)
        'path' => '/',
        'domain' => current_domain,
        'secure' => is_https,
        'httponly' => true,
        'samesite' => 'Lax'
     ])
  
  2. Set custom session save path
     session_save_path('/path/to/tmp')
  
  3. Set session name
     session_name('JOSECARE_SESSION')
  
  4. Start session
     IF session_status() == PHP_SESSION_NONE THEN
        session_start()
     END IF
  
  5. Initialize session variables if new
     IF NOT isset($_SESSION['initialized']) THEN
        $_SESSION['initialized'] = true
        $_SESSION['created_at'] = current_timestamp
        $_SESSION['user_agent'] = $_SERVER['HTTP_USER_AGENT']
        $_SESSION['ip_address'] = $_SERVER['REMOTE_ADDR']
     END IF
  
  6. Validate session integrity
     CALL Validate_Session_Integrity()
END PROCEDURE
```

### 2. Session Timeout Validation

```
PROCEDURE: Validate_Session_Timeout
INPUT: None
OUTPUT: void or redirect
BEGIN
  1. Get idle timeout for user's role
     IF isset($_SESSION['idle_time']) THEN
        idle_timeout = $_SESSION['idle_time'] * 60  -- Convert to seconds
     ELSE
        idle_timeout = 1800  -- Default 30 minutes
     END IF
  
  2. Calculate idle duration
     last_activity = $_SESSION['last_activity']
     current_time = time()
     idle_duration = current_time - last_activity
  
  3. Check if session has timed out
     IF idle_duration > idle_timeout THEN
        -- Auto-lock session
        CALL Lock_Session()
        SET flash_message = "Session locked due to inactivity"
        REDIRECT to lockscreen.php
        EXIT
     END IF
  
  4. Update last activity timestamp
     $_SESSION['last_activity'] = current_time
END PROCEDURE
```

### 3. Session Integrity Validation

```
PROCEDURE: Validate_Session_Integrity
INPUT: None
OUTPUT: void or destroy session
BEGIN
  1. Check user agent consistency
     IF isset($_SESSION['user_agent']) THEN
        IF $_SESSION['user_agent'] != $_SERVER['HTTP_USER_AGENT'] THEN
           CALL Logout_User()
           SET flash_message = "Session invalid: Security check failed"
           REDIRECT to login.php
           EXIT
        END IF
     END IF
  
  2. Check IP address (optional, can be disabled)
     IF STRICT_IP_CHECK ENABLED THEN
        IF isset($_SESSION['ip_address']) THEN
           IF $_SESSION['ip_address'] != $_SERVER['REMOTE_ADDR'] THEN
              CALL Logout_User()
              SET flash_message = "Session invalid: IP address mismatch"
              REDIRECT to login.php
              EXIT
           END IF
        END IF
     END IF
  
  3. Check session age
     max_session_age = 86400  -- 24 hours
     IF (current_time - $_SESSION['created_at']) > max_session_age THEN
        CALL Logout_User()
        SET flash_message = "Session expired: Please login again"
        REDIRECT to login.php
        EXIT
     END IF
END PROCEDURE
```

### 4. Idle Timeout Client-Side Monitoring

```
PROCEDURE: Monitor_User_Activity (JavaScript)
INPUT: idle_timeout_minutes
OUTPUT: auto_lock or warning
BEGIN
  1. Initialize activity tracking
     last_activity = current_timestamp
     warning_shown = false
     warning_time = idle_timeout - 120  -- 2 minutes before timeout
  
  2. Register activity event listeners
     LISTEN TO:
        - mousemove
        - keypress
        - click
        - scroll
        - touchstart
  
  3. On activity event
     UPDATE last_activity = current_timestamp
     IF warning_shown THEN
        HIDE warning notification
        warning_shown = false
     END IF
  
  4. Start activity monitor (runs every 10 seconds)
     INTERVAL_FUNCTION check_activity() {
        elapsed_time = current_timestamp - last_activity
        
        -- Show warning
        IF elapsed_time >= warning_time AND NOT warning_shown THEN
           SHOW warning_toast("Session will lock in 2 minutes")
           warning_shown = true
        END IF
        
        -- Auto-lock
        IF elapsed_time >= idle_timeout THEN
           CALL Update_Server_Activity()  -- Mark session as inactive
           REDIRECT to lock-session.php
        END IF
     }
  
  5. Server activity update (every 60 seconds)
     INTERVAL_FUNCTION update_server() {
        AJAX POST to update-activity.php
        SEND: { timestamp: current_timestamp }
     }
END PROCEDURE
```

### 5. Session Cleanup Procedure

```
PROCEDURE: Cleanup_Old_Sessions
INPUT: None
OUTPUT: number_of_deleted_sessions
BEGIN
  1. Define cleanup threshold
     max_lifetime = 86400  -- 24 hours
  
  2. Get session save path
     session_path = session_save_path()
  
  3. Scan session files
     session_files = scandir(session_path)
  
  4. FOR EACH file IN session_files
        IF file_starts_with("sess_") THEN
           file_path = session_path + "/" + file
           file_modified_time = filemtime(file_path)
           file_age = current_time - file_modified_time
           
           IF file_age > max_lifetime THEN
              DELETE file_path
              deleted_count++
           END IF
        END IF
     END FOR
  
  5. RETURN deleted_count
END PROCEDURE
```

---

## Security Procedures

### 1. Password Hashing Procedure

```
PROCEDURE: Hash_Password
INPUT: plain_password
OUTPUT: hashed_password
BEGIN
  1. Validate password strength
     IF length(plain_password) < 8 THEN
        THROW "Password too short"
     END IF
  
  2. Hash password using bcrypt
     hashed_password = password_hash(
        plain_password,
        PASSWORD_BCRYPT,
        ['cost' => 12]
     )
  
  3. RETURN hashed_password
END PROCEDURE
```

### 2. Password Verification Procedure

```
PROCEDURE: Verify_Password
INPUT: plain_password, hashed_password
OUTPUT: boolean (is_valid)
BEGIN
  1. Verify password hash
     is_valid = password_verify(plain_password, hashed_password)
  
  2. Check if rehash is needed (algorithm updated)
     IF is_valid AND password_needs_rehash(hashed_password, PASSWORD_BCRYPT) THEN
        -- Update password hash in database
        new_hash = password_hash(plain_password, PASSWORD_BCRYPT, ['cost' => 12])
        CALL Update_User_Password(user_id, new_hash)
     END IF
  
  3. RETURN is_valid
END PROCEDURE
```

### 3. Input Sanitization Procedure

```
PROCEDURE: Sanitize_Input
INPUT: raw_input, input_type
OUTPUT: sanitized_input
BEGIN
  1. Trim whitespace
     input = trim(raw_input)
  
  2. Apply type-specific sanitization
     SWITCH input_type
        CASE 'email':
           input = filter_var(input, FILTER_SANITIZE_EMAIL)
           input = strtolower(input)
        
        CASE 'string':
           input = htmlspecialchars(input, ENT_QUOTES, 'UTF-8')
        
        CASE 'integer':
           input = filter_var(input, FILTER_SANITIZE_NUMBER_INT)
           input = intval(input)
        
        CASE 'url':
           input = filter_var(input, FILTER_SANITIZE_URL)
        
        CASE 'html':
           input = strip_tags(input, '<p><br><strong><em>')
     END SWITCH
  
  3. RETURN sanitized_input
END PROCEDURE
```

### 4. SQL Injection Prevention

```
PROCEDURE: Execute_Safe_Query
INPUT: query_string, parameters
OUTPUT: query_result
BEGIN
  1. Get database connection
     pdo = CALL Get_Database_Connection()
  
  2. Prepare statement
     TRY
        stmt = pdo->prepare(query_string)
     CATCH PDOException
        LOG error
        THROW "Database error"
     END TRY
  
  3. Bind parameters (automatic type detection)
     FOR EACH param IN parameters
        -- PDO automatically handles parameter binding
        -- No manual escaping needed
     END FOR
  
  4. Execute statement
     TRY
        success = stmt->execute(parameters)
     CATCH PDOException
        LOG error details
        THROW user-friendly error
     END TRY
  
  5. RETURN statement object
END PROCEDURE
```

### 5. XSS Prevention Procedure

```
PROCEDURE: Output_Safe_Content
INPUT: content, context
OUTPUT: escaped_content
BEGIN
  1. Determine output context
     SWITCH context
        CASE 'html':
           -- Escape HTML special characters
           safe_content = htmlspecialchars(
              content,
              ENT_QUOTES | ENT_HTML5,
              'UTF-8'
           )
        
        CASE 'attribute':
           -- Escape for HTML attribute
           safe_content = htmlspecialchars(
              content,
              ENT_QUOTES,
              'UTF-8'
           )
        
        CASE 'javascript':
           -- Escape for JavaScript string
           safe_content = json_encode(content, JSON_HEX_TAG | JSON_HEX_AMP)
        
        CASE 'url':
           -- Encode for URL
           safe_content = urlencode(content)
     END SWITCH
  
  2. RETURN safe_content
END PROCEDURE
```

### 6. CSRF Token Generation and Validation

```
PROCEDURE: Generate_CSRF_Token
INPUT: None
OUTPUT: csrf_token
BEGIN
  1. Generate random token
     IF NOT isset($_SESSION['csrf_token']) THEN
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32))
     END IF
  
  2. RETURN $_SESSION['csrf_token']
END PROCEDURE

PROCEDURE: Validate_CSRF_Token
INPUT: submitted_token
OUTPUT: boolean (is_valid)
BEGIN
  1. Check if session token exists
     IF NOT isset($_SESSION['csrf_token']) THEN
        RETURN false
     END IF
  
  2. Compare tokens using timing-safe comparison
     is_valid = hash_equals($_SESSION['csrf_token'], submitted_token)
  
  3. RETURN is_valid
END PROCEDURE
```

---

## Database Procedures

### 1. Database Schema Management

```sql
-- Users Table Creation Procedure
PROCEDURE: Create_Users_Table
BEGIN
  CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    role_id INT NOT NULL DEFAULT 5,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    FOREIGN KEY (role_id) REFERENCES roles(id)
      ON DELETE RESTRICT
      ON UPDATE CASCADE
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
END PROCEDURE
```

```sql
-- Roles Table Creation Procedure
PROCEDURE: Create_Roles_Table
BEGIN
  CREATE TABLE IF NOT EXISTS roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    idle_time INT NOT NULL DEFAULT 30 COMMENT 'Idle timeout in minutes',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
  
  -- Insert default roles
  INSERT IGNORE INTO roles (id, name, description, idle_time) VALUES
    (1, 'admin', 'Administrator with full system access', 30),
    (2, 'doctor', 'Medical doctor with patient management access', 20),
    (3, 'nurse', 'Nurse with patient care access', 15),
    (4, 'staff', 'General staff member', 15),
    (5, 'patient', 'Patient with limited access', 10);
END PROCEDURE
```

```sql
-- Remember Tokens Table Creation Procedure
PROCEDURE: Create_Remember_Tokens_Table
BEGIN
  CREATE TABLE IF NOT EXISTS remember_tokens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    selector VARCHAR(255) NOT NULL UNIQUE,
    hashed_validator VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_selector (selector),
    INDEX idx_expires (expires_at),
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
END PROCEDURE
```

### 2. User CRUD Operations

```
PROCEDURE: Create_User_Record
INPUT: email, hashed_password, role_id, full_name
OUTPUT: user_id or error
BEGIN
  1. Prepare INSERT statement
     query = "INSERT INTO users (email, password, role_id, full_name)
              VALUES (?, ?, ?, ?)"
  
  2. Execute with parameters
     TRY
        EXECUTE query WITH [email, hashed_password, role_id, full_name]
        user_id = last_insert_id()
        RETURN user_id
     CATCH PDOException
        IF error_code == 23000 THEN  -- Duplicate entry
           RETURN error: "Email already exists"
        ELSE
           LOG error
           RETURN error: "Database error"
        END IF
     END TRY
END PROCEDURE
```

```
PROCEDURE: Read_User_By_Email
INPUT: email
OUTPUT: user_data or null
BEGIN
  1. Prepare SELECT statement with role join
     query = "SELECT u.id, u.email, u.password, u.full_name, u.role_id,
                     r.name as role_name, r.description as role_description,
                     r.idle_time, u.last_login, u.created_at
              FROM users u
              LEFT JOIN roles r ON u.role_id = r.id
              WHERE u.email = ?"
  
  2. Execute query
     result = EXECUTE query WITH [email]
  
  3. Fetch and return user data
     IF result.rowCount > 0 THEN
        RETURN result.fetch()
     ELSE
        RETURN null
     END IF
END PROCEDURE
```

```
PROCEDURE: Update_User_Record
INPUT: user_id, fields_to_update
OUTPUT: success_status
BEGIN
  1. Build dynamic UPDATE statement
     SET clauses = []
     parameters = []
     
     FOR EACH field, value IN fields_to_update
        ADD field + " = ?" TO SET clauses
        ADD value TO parameters
     END FOR
     
     query = "UPDATE users SET " + JOIN(SET clauses, ", ") + 
             " WHERE id = ?"
     ADD user_id TO parameters
  
  2. Execute update
     TRY
        EXECUTE query WITH parameters
        RETURN success
     CATCH PDOException
        LOG error
        RETURN failure
     END TRY
END PROCEDURE
```

```
PROCEDURE: Delete_User_Record
INPUT: user_id
OUTPUT: success_status
BEGIN
  1. Begin transaction
     BEGIN TRANSACTION
  
  2. Delete related records (cascade should handle this)
     -- Remember tokens will cascade delete
     -- Check for other dependencies
  
  3. Delete user
     query = "DELETE FROM users WHERE id = ?"
     EXECUTE query WITH [user_id]
  
  4. Commit transaction
     COMMIT TRANSACTION
  
  5. RETURN success
  
  ON ERROR:
     ROLLBACK TRANSACTION
     LOG error
     RETURN failure
END PROCEDURE
```

### 3. Token Management

```
PROCEDURE: Cleanup_Expired_Tokens
INPUT: None
OUTPUT: number_of_deleted_tokens
BEGIN
  1. Delete expired remember tokens
     query = "DELETE FROM remember_tokens WHERE expires_at < NOW()"
     result = EXECUTE query
  
  2. RETURN result.rowCount
END PROCEDURE
```

```
PROCEDURE: Delete_User_Tokens
INPUT: user_id
OUTPUT: success_status
BEGIN
  1. Delete all tokens for user
     query = "DELETE FROM remember_tokens WHERE user_id = ?"
     EXECUTE query WITH [user_id]
  
  2. RETURN success
END PROCEDURE
```

---

## UI/Frontend Procedures

### 1. Form Validation (Client-Side)

```javascript
PROCEDURE: Validate_Login_Form (JavaScript)
INPUT: form_data
OUTPUT: validation_result
BEGIN
  1. Initialize validation result
     errors = []
     is_valid = true
  
  2. Validate email field
     IF email is empty THEN
        ADD "Email is required" TO errors
        is_valid = false
     ELSE IF NOT valid_email_format(email) THEN
        ADD "Invalid email format" TO errors
        is_valid = false
     END IF
  
  3. Validate password field
     IF password is empty THEN
        ADD "Password is required" TO errors
        is_valid = false
     END IF
  
  4. Display validation errors
     IF errors.length > 0 THEN
        FOR EACH error IN errors
           DISPLAY error message next to field
        END FOR
     END IF
  
  5. RETURN is_valid
END PROCEDURE
```

```javascript
PROCEDURE: Validate_Registration_Form (JavaScript)
INPUT: form_data
OUTPUT: validation_result
BEGIN
  1. Initialize validation
     errors = []
     is_valid = true
  
  2. Validate full name
     IF full_name is empty THEN
        ADD error
        is_valid = false
     END IF
  
  3. Validate email
     IF email is empty THEN
        ADD "Email is required" TO errors
        is_valid = false
     ELSE IF NOT valid_email_format(email) THEN
        ADD "Invalid email format" TO errors
        is_valid = false
     END IF
  
  4. Validate password
     IF password is empty THEN
        ADD error
        is_valid = false
     ELSE IF password.length < 8 THEN
        ADD "Password must be at least 8 characters" TO errors
        is_valid = false
     END IF
  
  5. Validate password confirmation
     IF password != confirm_password THEN
        ADD "Passwords do not match" TO errors
        is_valid = false
     END IF
  
  6. Check password strength
     strength = CALL Calculate_Password_Strength(password)
     DISPLAY strength indicator
  
  7. Validate terms checkbox
     IF NOT terms_checked THEN
        ADD "You must accept terms and conditions" TO errors
        is_valid = false
     END IF
  
  8. Display errors
     UPDATE UI with validation errors
  
  9. RETURN is_valid
END PROCEDURE
```

### 2. Flash Message Display

```
PROCEDURE: Display_Flash_Message
INPUT: None (reads from session)
OUTPUT: HTML message element
BEGIN
  1. Check if flash message exists
     IF NOT isset($_SESSION['flash_message']) THEN
        RETURN empty string
     END IF
  
  2. Get message data
     message = $_SESSION['flash_message']['message']
     type = $_SESSION['flash_message']['type']  -- success, error, warning, info
  
  3. Map type to Bootstrap alert class
     SWITCH type
        CASE 'success': class = 'alert-success'
        CASE 'error': class = 'alert-danger'
        CASE 'warning': class = 'alert-warning'
        CASE 'info': class = 'alert-info'
        DEFAULT: class = 'alert-info'
     END SWITCH
  
  4. Generate HTML
     html = '<div class="alert ' + class + ' alert-dismissible fade show" role="alert">'
     html += message
     html += '<button type="button" class="btn-close" data-bs-dismiss="alert"></button>'
     html += '</div>'
  
  5. Clear flash message from session
     UNSET $_SESSION['flash_message']
  
  6. RETURN html
END PROCEDURE
```

### 3. Dynamic UI Updates

```javascript
PROCEDURE: Update_Session_Timer_Display (JavaScript)
INPUT: None
OUTPUT: Updated UI
BEGIN
  1. Get session timeout value
     AJAX GET request to check-session.php
  
  2. Calculate remaining time
     remaining = timeout - elapsed_time
  
  3. Update UI timer
     IF remaining > 0 THEN
        minutes = floor(remaining / 60)
        seconds = remaining % 60
        DISPLAY "Session expires in: " + minutes + ":" + seconds
     ELSE
        DISPLAY "Session expired"
        REDIRECT to lock-session.php
     END IF
END PROCEDURE
```

---

## Error Handling Procedures

### 1. Global Error Handler

```
PROCEDURE: Handle_Error
INPUT: error_type, error_message, file, line
OUTPUT: error_response
BEGIN
  1. Log error details
     error_log = {
        timestamp: current_timestamp,
        type: error_type,
        message: error_message,
        file: file,
        line: line,
        user_id: $_SESSION['user_id'] ?? 'guest',
        url: $_SERVER['REQUEST_URI'],
        ip: $_SERVER['REMOTE_ADDR']
     }
     
     WRITE error_log TO error_log_file
  
  2. Determine if error is critical
     IF error_type IN ['E_ERROR', 'E_CORE_ERROR', 'E_COMPILE_ERROR'] THEN
        is_critical = true
     ELSE
        is_critical = false
     END IF
  
  3. Generate user-friendly message
     IF is_production_mode THEN
        user_message = "An error occurred. Please try again later."
     ELSE
        user_message = error_message  -- Show details in development
     END IF
  
  4. IF is_critical THEN
        -- Display error page
        INCLUDE error_page_template
        EXIT
     ELSE
        -- Set flash message
        SET flash_message = user_message
        RETURN
     END IF
END PROCEDURE
```

### 2. Database Error Handling

```
PROCEDURE: Handle_Database_Error
INPUT: PDOException exception
OUTPUT: user_message
BEGIN
  1. Log detailed error
     LOG exception.getMessage()
     LOG exception.getTraceAsString()
  
  2. Determine error type
     error_code = exception.getCode()
     
     SWITCH error_code
        CASE '23000':  -- Integrity constraint violation
           user_message = "Duplicate entry or invalid data"
        
        CASE '42S02':  -- Table not found
           user_message = "Database configuration error"
        
        CASE '08S01':  -- Connection error
           user_message = "Database connection failed"
        
        DEFAULT:
           user_message = "Database error occurred"
     END SWITCH
  
  3. IF is_production_mode THEN
        user_message = "A database error occurred. Please try again."
     END IF
  
  4. RETURN user_message
END PROCEDURE
```

### 3. Validation Error Collection

```
PROCEDURE: Collect_Validation_Errors
INPUT: field_validations
OUTPUT: error_array
BEGIN
  1. Initialize errors array
     errors = []
  
  2. FOR EACH field, rules IN field_validations
        FOR EACH rule IN rules
           SWITCH rule.type
              CASE 'required':
                 IF field_value is empty THEN
                    ADD rule.message TO errors[field]
                 END IF
              
              CASE 'min_length':
                 IF length(field_value) < rule.value THEN
                    ADD rule.message TO errors[field]
                 END IF
              
              CASE 'max_length':
                 IF length(field_value) > rule.value THEN
                    ADD rule.message TO errors[field]
                 END IF
              
              CASE 'email':
                 IF NOT valid_email(field_value) THEN
                    ADD rule.message TO errors[field]
                 END IF
              
              CASE 'match':
                 IF field_value != other_field_value THEN
                    ADD rule.message TO errors[field]
                 END IF
           END SWITCH
        END FOR
     END FOR
  
  3. RETURN errors
END PROCEDURE
```

---

## Maintenance Procedures

### 1. Database Backup Procedure

```bash
PROCEDURE: Backup_Database
INPUT: database_name
OUTPUT: backup_file
BEGIN
  1. Generate backup filename
     timestamp = current_date_time
     backup_file = "backup_" + database_name + "_" + timestamp + ".sql"
  
  2. Execute mysqldump
     EXECUTE COMMAND:
        mysqldump -u DB_USER -p DB_NAME > backups/backup_file
  
  3. Compress backup
     EXECUTE COMMAND:
        gzip backups/backup_file
  
  4. Verify backup file exists and size > 0
     IF file_exists AND file_size > 0 THEN
        LOG "Backup successful: " + backup_file
     ELSE
        LOG "Backup failed"
        SEND alert to admin
     END IF
  
  5. Clean old backups (keep last 30 days)
     FOR EACH file IN backups directory
        IF file_age > 30 days THEN
           DELETE file
        END IF
     END FOR
END PROCEDURE
```

### 2. Session Cleanup Cron Job

```bash
PROCEDURE: Cleanup_Sessions_Cron
INPUT: None
OUTPUT: cleanup_log
BEGIN
  1. Log start time
     LOG "Session cleanup started at " + current_timestamp
  
  2. Call PHP cleanup script
     EXECUTE COMMAND:
        php /path/to/cleanup-sessions.php
  
  3. Call token cleanup
     EXECUTE COMMAND:
        php /path/to/cleanup-tokens.php
  
  4. Log completion
     LOG "Session cleanup completed at " + current_timestamp
END PROCEDURE

-- Crontab entry (runs daily at 2 AM)
-- 0 2 * * * /path/to/cleanup_sessions_cron.sh >> /var/log/josecare/cleanup.log 2>&1
```

### 3. Security Audit Procedure

```
PROCEDURE: Run_Security_Audit
INPUT: None
OUTPUT: audit_report
BEGIN
  1. Check for weak passwords
     EXECUTE QUERY:
        "SELECT id, email FROM users 
         WHERE LENGTH(password) < 60"  -- Bcrypt hashes are 60 chars
     
     IF weak_passwords_found THEN
        ADD to audit_report: "Weak password hashes detected"
     END IF
  
  2. Check for inactive admin accounts
     EXECUTE QUERY:
        "SELECT u.id, u.email, u.last_login
         FROM users u
         JOIN roles r ON u.role_id = r.id
         WHERE r.name = 'admin'
         AND (u.last_login IS NULL OR u.last_login < DATE_SUB(NOW(), INTERVAL 90 DAY))"
     
     IF inactive_admins_found THEN
        ADD to audit_report: "Inactive admin accounts found"
     END IF
  
  3. Check for expired remember tokens
     EXECUTE QUERY:
        "SELECT COUNT(*) FROM remember_tokens WHERE expires_at < NOW()"
     
     IF expired_tokens > 0 THEN
        CALL Cleanup_Expired_Tokens()
        ADD to audit_report: expired_tokens + " expired tokens cleaned"
     END IF
  
  4. Check file permissions
     critical_files = [
        'config/database.php',
        'includes/auth.php',
        '.htaccess'
     ]
     
     FOR EACH file IN critical_files
        permissions = GET file_permissions(file)
        IF permissions > 0644 THEN
           ADD to audit_report: file + " has insecure permissions"
        END IF
     END FOR
  
  5. Check for SQL injection vulnerabilities
     -- Review all queries for proper parameter binding
     -- This is a manual code review process
  
  6. Generate report
     report = {
        timestamp: current_timestamp,
        findings: audit_report,
        status: audit_report.isEmpty() ? 'PASS' : 'ISSUES_FOUND'
     }
     
     SAVE report TO audit_log
     RETURN report
END PROCEDURE
```

### 4. User Activity Report

```
PROCEDURE: Generate_Activity_Report
INPUT: start_date, end_date
OUTPUT: activity_report
BEGIN
  1. Query user login statistics
     EXECUTE QUERY:
        "SELECT 
           DATE(last_login) as login_date,
           COUNT(*) as login_count,
           COUNT(DISTINCT user_id) as unique_users
         FROM users
         WHERE last_login BETWEEN ? AND ?
         GROUP BY DATE(last_login)
         ORDER BY login_date DESC"
     WITH PARAMETERS: [start_date, end_date]
  
  2. Query role distribution
     EXECUTE QUERY:
        "SELECT r.name, COUNT(u.id) as user_count
         FROM roles r
         LEFT JOIN users u ON r.id = u.role_id
         GROUP BY r.id, r.name"
  
  3. Query new registrations
     EXECUTE QUERY:
        "SELECT DATE(created_at) as registration_date,
                COUNT(*) as new_users
         FROM users
         WHERE created_at BETWEEN ? AND ?
         GROUP BY DATE(created_at)"
     WITH PARAMETERS: [start_date, end_date]
  
  4. Compile report
     report = {
        period: {start: start_date, end: end_date},
        login_statistics: login_stats,
        role_distribution: role_dist,
        new_registrations: new_users,
        generated_at: current_timestamp
     }
  
  5. Format report as HTML/PDF
     formatted_report = CALL Format_Report(report)
  
  6. RETURN formatted_report
END PROCEDURE
```

---

## System Integration Procedures

### 1. Page Load Sequence

```
PROCEDURE: Load_Protected_Page
INPUT: page_url
OUTPUT: rendered_page
BEGIN
  1. Include access control
     INCLUDE 'adm/access.php'
     -- This calls Require_Authentication()
  
  2. Include template header
     INCLUDE 'adm/tmpl_up.php'
     -- Initializes session, loads config
  
  3. Include navigation header
     INCLUDE 'adm/header.php'
     -- Displays user menu, logout option
  
  4. Include sidebar
     INCLUDE 'adm/sidebar.php'
     -- Displays navigation menu
  
  5. Render page content
     -- Page-specific content goes here
  
  6. Include template footer
     INCLUDE 'adm/tmpl_down.php'
     -- Closes HTML tags, includes scripts
  
  7. Output buffered content
     FLUSH output buffer
END PROCEDURE
```

### 2. AJAX Request Handling

```javascript
PROCEDURE: Handle_AJAX_Request (JavaScript)
INPUT: endpoint, data, method
OUTPUT: response
BEGIN
  1. Prepare request
     request = {
        url: endpoint,
        method: method,
        data: data,
        headers: {
           'Content-Type': 'application/json',
           'X-Requested-With': 'XMLHttpRequest'
        }
     }
  
  2. Send request
     TRY
        response = AWAIT fetch(request)
        
        IF response.status == 200 THEN
           result = AWAIT response.json()
           RETURN result
        
        ELSE IF response.status == 401 THEN
           -- Unauthorized
           REDIRECT to login.php
        
        ELSE IF response.status == 403 THEN
           -- Forbidden
           SHOW error: "Access denied"
        
        ELSE
           SHOW error: "Request failed"
        END IF
     
     CATCH error
        LOG error
        SHOW error: "Network error occurred"
     END TRY
END PROCEDURE
```

```php
PROCEDURE: Process_AJAX_Request (PHP)
INPUT: $_POST or $_GET data
OUTPUT: JSON response
BEGIN
  1. Verify AJAX request
     IF NOT isset($_SERVER['HTTP_X_REQUESTED_WITH']) THEN
        SEND JSON: {error: "Invalid request"}
        EXIT
     END IF
  
  2. Verify authentication
     CALL Require_Authentication()
  
  3. Parse input data
     IF $_SERVER['REQUEST_METHOD'] == 'POST' THEN
        data = json_decode(file_get_contents('php://input'), true)
     ELSE
        data = $_GET
     END IF
  
  4. Process request based on action
     action = data['action']
     
     SWITCH action
        CASE 'update_activity':
           CALL Update_User_Activity()
           response = {success: true}
        
        CASE 'check_session':
           is_valid = CALL Validate_Session()
           response = {valid: is_valid}
        
        DEFAULT:
           response = {error: "Unknown action"}
     END SWITCH
  
  5. Send JSON response
     header('Content-Type: application/json')
     echo json_encode(response)
     EXIT
END PROCEDURE
```

---

## Performance Optimization Procedures

### 1. Query Optimization

```
PROCEDURE: Optimize_Database_Queries
INPUT: None
OUTPUT: optimization_report
BEGIN
  1. Analyze slow queries
     EXECUTE QUERY:
        "SELECT * FROM mysql.slow_log
         ORDER BY query_time DESC
         LIMIT 10"
  
  2. Check missing indexes
     FOR EACH table IN database
        EXECUTE QUERY: "SHOW INDEX FROM " + table
        
        -- Identify frequently queried columns without indexes
        IF column_used_in_where AND NOT indexed THEN
           ADD to recommendations: "Add index on " + table + "." + column
        END IF
     END FOR
  
  3. Optimize frequently used queries
     -- Add composite indexes for complex queries
     -- Example: email + role_id lookup
     EXECUTE QUERY:
        "CREATE INDEX idx_email_role ON users(email, role_id)"
  
  4. Update table statistics
     FOR EACH table IN database
        EXECUTE QUERY: "ANALYZE TABLE " + table
     END FOR
  
  5. RETURN optimization_report
END PROCEDURE
```

### 2. Session Storage Optimization

```
PROCEDURE: Optimize_Session_Storage
INPUT: None
OUTPUT: None
BEGIN
  1. Configure session garbage collection
     ini_set('session.gc_probability', 1)
     ini_set('session.gc_divisor', 100)
     ini_set('session.gc_maxlifetime', 86400)
  
  2. Consider alternative session handlers
     -- For high-traffic sites, use Redis or Memcached
     IF using_redis THEN
        ini_set('session.save_handler', 'redis')
        ini_set('session.save_path', 'tcp://127.0.0.1:6379')
     END IF
  
  3. Minimize session data size
     -- Store only essential data in session
     -- Move large data to database
END PROCEDURE
```

---

## Disaster Recovery Procedures

### 1. Database Restore Procedure

```bash
PROCEDURE: Restore_Database
INPUT: backup_file
OUTPUT: restore_status
BEGIN
  1. Verify backup file exists
     IF NOT file_exists(backup_file) THEN
        LOG "Backup file not found"
        RETURN failure
     END IF
  
  2. Decompress backup if needed
     IF backup_file ends with .gz THEN
        EXECUTE COMMAND: gunzip backup_file
        backup_file = remove .gz extension
     END IF
  
  3. Create new database or drop existing
     EXECUTE COMMAND:
        mysql -u root -p -e "DROP DATABASE IF EXISTS josenicare_db"
        mysql -u root -p -e "CREATE DATABASE josenicare_db"
  
  4. Restore from backup
     EXECUTE COMMAND:
        mysql -u root -p josenicare_db < backup_file
  
  5. Verify restoration
     EXECUTE COMMAND:
        mysql -u root -p josenicare_db -e "SHOW TABLES"
     
     IF tables_exist THEN
        LOG "Database restored successfully"
        RETURN success
     ELSE
        LOG "Database restoration failed"
        RETURN failure
     END IF
END PROCEDURE
```

### 2. Emergency Session Cleanup

```
PROCEDURE: Emergency_Session_Cleanup
INPUT: None
OUTPUT: cleanup_status
BEGIN
  1. Stop web server
     EXECUTE COMMAND: systemctl stop apache2
  
  2. Backup current sessions
     EXECUTE COMMAND:
        cp -r /path/to/sessions /path/to/sessions.backup
  
  3. Clear all sessions
     EXECUTE COMMAND:
        rm -rf /path/to/sessions/*
  
  4. Recreate session directory
     EXECUTE COMMAND:
        mkdir -p /path/to/sessions
        chmod 700 /path/to/sessions
        chown www-data:www-data /path/to/sessions
  
  5. Start web server
     EXECUTE COMMAND: systemctl start apache2
  
  6. Verify server is running
     EXECUTE COMMAND: systemctl status apache2
  
  7. Log all users out (via database)
     -- Sessions are cleared, users must re-login
  
  8. RETURN cleanup_status
END PROCEDURE
```

---

## Testing Procedures

### 1. Authentication Testing

```
PROCEDURE: Test_Authentication_Flow
INPUT: test_credentials
OUTPUT: test_results
BEGIN
  1. Test user registration
     result = CALL Register_User(test_email, test_password)
     ASSERT result.success == true
     ASSERT user_exists_in_database
  
  2. Test login with valid credentials
     result = CALL Login_User(test_email, test_password)
     ASSERT result.success == true
     ASSERT session_created
  
  3. Test login with invalid credentials
     result = CALL Login_User(test_email, wrong_password)
     ASSERT result.success == false
     ASSERT error_message_shown
  
  4. Test session lock
     CALL Lock_Session()
     ASSERT session_locked == true
     ASSERT cannot_access_protected_pages
  
  5. Test session unlock
     result = CALL Unlock_Session(test_password)
     ASSERT result.success == true
     ASSERT session_active
  
  6. Test logout
     CALL Logout_User()
     ASSERT session_destroyed
     ASSERT cannot_access_protected_pages
  
  7. RETURN test_results
END PROCEDURE
```

### 2. Security Testing

```
PROCEDURE: Test_Security_Measures
INPUT: None
OUTPUT: security_test_results
BEGIN
  1. Test SQL injection prevention
     malicious_input = "' OR '1'='1"
     result = CALL Login_User(malicious_input, "password")
     ASSERT result.success == false
     ASSERT no_database_error
  
  2. Test XSS prevention
     malicious_script = "<script>alert('XSS')</script>"
     CALL Register_User(malicious_script + "@test.com", "password")
     -- Check that script is escaped in output
     ASSERT output_is_escaped
  
  3. Test CSRF protection
     -- Attempt form submission without CSRF token
     ASSERT request_rejected
  
  4. Test session hijacking prevention
     -- Change user agent mid-session
     ASSERT session_invalidated
  
  5. Test password hashing
     password = "test123456"
     hash = CALL Hash_Password(password)
     ASSERT hash starts with "$2y$"  -- Bcrypt identifier
     ASSERT length(hash) == 60
  
  6. RETURN security_test_results
END PROCEDURE
```

---

## Monitoring Procedures

### 1. System Health Check

```
PROCEDURE: Check_System_Health
INPUT: None
OUTPUT: health_status
BEGIN
  1. Check database connection
     TRY
        CALL Get_Database_Connection()
        db_status = "OK"
     CATCH
        db_status = "FAILED"
     END TRY
  
  2. Check session directory writable
     IF is_writable(session_save_path()) THEN
        session_status = "OK"
     ELSE
        session_status = "NOT WRITABLE"
     END IF
  
  3. Check disk space
     free_space = disk_free_space("/")
     IF free_space < 1GB THEN
        disk_status = "LOW"
     ELSE
        disk_status = "OK"
     END IF
  
  4. Check active sessions count
     session_count = COUNT files in session directory
  
  5. Compile health report
     health_status = {
        database: db_status,
        sessions: session_status,
        disk: disk_status,
        active_sessions: session_count,
        timestamp: current_timestamp
     }
  
  6. RETURN health_status
END PROCEDURE
```

---

## Conclusion

This procedural design layout provides a comprehensive view of the JoseCare system's operations, from high-level architecture down to specific implementation procedures. Each procedure is designed with security, reliability, and maintainability in mind.

### Key Takeaways:
1. **Layered Architecture**: Clear separation of concerns across presentation, application, business logic, data access, and database layers
2. **Security-First Design**: Every procedure incorporates security best practices
3. **Error Handling**: Comprehensive error handling at every level
4. **Maintainability**: Modular procedures that are easy to test and maintain
5. **Scalability**: Procedures designed to handle growth in users and data

### Implementation Guidelines:
- Follow the procedural flow for all new features
- Maintain consistent error handling patterns
- Document any deviations from these procedures
- Regular security audits and testing
- Continuous monitoring and optimization

---

**Document Version**: 1.0  
**Last Updated**: November 24, 2025  
**System**: JoseCare 
