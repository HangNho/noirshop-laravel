<?php

use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\HomeController;
use App\Http\Controllers\ShopController;
use App\Http\Controllers\Products;

use Illuminate\Support\Facades\Route;


Route::get('/', [HomeController::class, 'index'])->name('home');
Route::get('/shop',[ShopController::class,'shop'])->name('shop');
Route::get('/product',[Products::class,'product'])->name('product');

Route::get('/login', [AuthController::class, 'index'])->name('login');
Route::post('/login/attempt', [AuthController::class, 'attempt']);

Route::get('/register', [AuthController::class, 'create'])->name('register');
Route::post('/register/store', [AuthController::class, 'store']);

Route::get('/logout', [AuthController::class, 'destroy']);



// ADMIN

Route::get('/admin', [DashboardController::class, 'index'])->name('admin');