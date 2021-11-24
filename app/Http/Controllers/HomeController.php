<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class HomeController extends Controller
{
    public function index()
    {
        $logged = Auth::check();
        return view('home', [
            'title' => 'Home',
            'logged' => $logged
        ]);
    }
}
