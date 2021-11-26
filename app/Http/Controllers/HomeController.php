<?php

namespace App\Http\Controllers;

use App\Models\Category;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class HomeController extends Controller
{
    public function index()
    {
        $logged = Auth::check();

        $categories = Category::all();
        $products = Product::all();

        return view('home', [
            'title' => 'Home',
            'categories' => $categories,
            'pproducts' => $products,
            'logged' => $logged
        ]);
    }
}
