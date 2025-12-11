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
        'purpose' => 'required|string',
        'status' => 'required|string',
        'schedule' => 'required|date',
    ])->validate();

    DB::table('appointments')->insert([
        'campus' => $validated['campus'],
        'type' => $validated['type'],
        'purpose' => $validated['purpose'],
        'status' => $validated['status'],
        'schedule' => $validated['schedule'],
        'created_at' => now(),
    ]);

    return response()->json([
        'success' => true,
        'message' => 'Appointment created',
        'appointment' => $validated,
    ]);
}


 public function getPendingSlots(Request $request)
    {
        $request->validate([
            'date' => 'required|date'
        ]);

        $pending = DB::table('appointments')
            ->whereDate('schedule', $request->date)
            ->where('status', 'pending')
            ->get(['id', 'schedule', 'status']);

        return response()->json([
            'date' => $request->date,
            'pending_slots' => $pending
        ]);
    }

}

   


