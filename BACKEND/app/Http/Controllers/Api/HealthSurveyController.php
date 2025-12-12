<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class HealthSurveyController extends Controller
{
    public function store(Request $request)
    {
        $data = $request->input('health_report');

        $validated = validator($data, [
            'health_rating'    => 'required|integer|min:0|max:10',
            'areaAffected'     => 'required|string',
            'symptoms' => 'required|array|min:1',
            'symptoms.*' => 'string',
            'date_started'     => 'required|date',
            'pain_rating'      => 'required|integer|min:0|max:10',
            'pain_location'    => 'required|string',
            'medication_taken' => 'required|boolean',
            'schedule'         => 'required|date',
        ])->validate();

        DB::table('healthSurvey')->insert([
            'health_rating'    => $validated['health_rating'],
            'areaAffected'     => $validated['areaAffected'],
            'symptoms'         => json_encode($validated['symptoms']),
            'date_started'     => $validated['date_started'],
            'pain_rating'      => $validated['pain_rating'],
            'pain_location'    => $validated['pain_location'],
            'medication_taken' => $validated['medication_taken'],
            'schedule'         => $validated['schedule'],
            'created_at'       => now(),
        ]);


        return response()->json([
            'success' => true,
            'message' => 'Health report created',
            'health_report' => $validated,
        ]);
    }

}
