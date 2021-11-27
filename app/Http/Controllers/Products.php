<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
class Products extends Controller
{
   // $logged = Auth::check();

    // $categories = Category::all();
    // $products = Product::all();

    public function product()
    {
        $logged = Auth::check();

       //$categories = Category::all();
       // $products = Product::all();

        return view('product', [
            'title' => 'product',
          //  'categories' => $categories,
           // 'pproducts' => $products,
           'logged' => $logged
        ]);
    }
}
