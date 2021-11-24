<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class LoginController extends Controller
{
    public function index(Request $request) {
        // if (isset(Auth::user())) {
        //     return redirect()->route('home');
        // }
        echo(Auth::user());
        return view('auth.login.index', ['title' => 'Login']);
    }

    public function store(Request $request) {
        $this->validate($request, [
            'email' => 'required|email:filter', 
            'password' => 'required'
        ]);

        $credentials = $request->only(['email', 'password']);
        if (Auth::attempt($credentials)) {
            return redirect()->route('home');
        } else {
            return redirect()->back()->withInput();
        }
    }
}