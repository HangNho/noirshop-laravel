<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Session;

class AuthController extends Controller
{
    public function index()
    {
        if (Auth::check()) {
            return redirect()->route('home');
        }
        return view('auth.login.index', ['title' => 'Login']);
    }

    public function attempt(Request $request) {
        $this->validate($request, [
            'email' => 'required|email:filter', 
            'password' => 'required'
        ]);

        $data = $request->only(['email', 'password']);
        if (Auth::attempt([
            'email' => $data['email'],
            'password' => $data['password'],
            'roll' => 'user'
        ], $request->input('remember'))) {
            
            return redirect()->route('home');
        
        } elseif (Auth::attempt([
            'email' => $data['email'],
            'password' => $data['password'],
            'roll' => 'admin'
        ], $request->input('remember'))) {
            return redirect()->route('admin');
        }

        Session::flash('error', 'Email hoặc mật khẩu không đúng!');
        return redirect()->back()->withInput();
    }

    public function create()
    {
        if (Auth::check()) {
            return redirect()->route('home');
        }
        return view('auth.register.index', ['title' => 'Register']);
    }

    public function store(Request $request)
    {
        $this->validate($request, [
            'name' => 'required',
            'email' => 'required|email:filter', 
            'password' => 'required',
            'passwordRetype' => 'required'
        ]);

        if ($request->input('password') === $request->input('passwordRetype')) {
            $user = User::create([
                'name' => $request->input('name'),
                'email' => $request->input('email'),
                'password' => bcrypt($request->input('password'))
            ]);

            $user->save();
            
            Session::flash('success', 'Đăng ký thành viên thành công ;)');
            return redirect()->back();
        }

        Session::flash('error', 'Thông tin không chính xác!');
        return redirect()->back()->withInput();
    }

    public function show($id)
    {
        //
    }

    public function edit($id)
    {
        //
    }

    public function update(Request $request, $id)
    {
        //
    }

    public function destroy()
    {
        Auth::logout();
        return redirect()->route('home');
    }
}
