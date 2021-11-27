<?php

namespace App\Http\Controllers;

//use App\Models\Category;
//use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ShopController extends Controller
{
    public function shop()
    {
        $logged = Auth::check();

       // $categories = Category::all();
       // $products = Product::all();

        return view('shop', [
            'title' => 'Shop',
          //  'categories' => $categories,
           // 'pproducts' => $products,
           // 'logged' => $logged
        ]);
    }
}
