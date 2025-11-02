<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB; 


class UserController extends Controller
{
    // GET all users
    public function index() {
        $users = DB::select("SELECT * FROM users");
        return response()->json($users);
    }

    // POST add a new user
    public function store(Request $request) {
        DB::insert("INSERT INTO users (name, email, password) VALUES (?, ?, ?)", [
            $request->name,
            $request->email,
            bcrypt($request->password)
        ]);
        return response()->json(['message' => 'User created']);
    }
}
