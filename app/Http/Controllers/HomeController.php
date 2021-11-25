<?php

namespace App\Http\Controllers;

use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class HomeController extends Controller
{
    public function index()
    {
        $logged = Auth::check();

        $categories = Category::all();

        return view('home', [
            'title' => 'Home',
            'categories' => $categories,
            'logged' => $logged
        ]);
    }
}
