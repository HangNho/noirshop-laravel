<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ContactController extends Controller
{
    public function index() {
        $logged = Auth::check();

        return view('contact', [
            'title' => 'Contact',
            'logged' => $logged
        ]);
    }
}
