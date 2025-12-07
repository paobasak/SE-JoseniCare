<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AppointmentController extends Controller
{
    public function store(Request $request){
    $data = $request->input('appointment');

    $validated = validator($data, [
        'campus' => 'required|string',
        'type'   => 'required|string',
    ])->validate();

    DB::table('appointments')->insert([
        'campus' => $validated['campus'],
        'type' => $validated['type'],
        'created_at' => now(),
    ]);

    return response()->json([
        'success' => true,
        'message' => 'Appointment created',
        'appointment' => $validated,
    ]);
}
}

   


