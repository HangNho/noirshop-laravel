<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class HomeController extends Controller
{
    public function index()
    {
        // $user = Auth::user();
        // echo 'Xin chào User, '. $user->name;
        return view('home', [
            'title' => 'Home'
        ]);
    }
}
