-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Nov 23, 2021 at 04:16 AM
-- Server version: 8.0.21
-- PHP Version: 7.3.21

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: ` noirshop_laravel`
--

-- --------------------------------------------------------

--
-- Table structure for table `bills`
--

DROP TABLE IF EXISTS `bills`;
CREATE TABLE IF NOT EXISTS `bills` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `total` bigint NOT NULL DEFAULT '0',
  `note` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `bills_user_id` (`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `bills`
--
DROP TRIGGER IF EXISTS `tg_DeleteBills_Before`;
DELIMITER $$
CREATE TRIGGER `tg_DeleteBills_Before` BEFORE DELETE ON `bills` FOR EACH ROW BEGIN
	set @id=old.id;
    IF EXISTS (SELECT id FROM bill_items WHERE bill_id=@id) THEN
        delete from bill_items where bill_items.bill_id=@id;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `bill_items`
--

DROP TABLE IF EXISTS `bill_items`;
CREATE TABLE IF NOT EXISTS `bill_items` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `bill_id` bigint UNSIGNED NOT NULL,
  `product_id` bigint UNSIGNED NOT NULL,
  `product_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `current_price` bigint DEFAULT NULL,
  `quantity` int NOT NULL,
  `total` bigint DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `bill_items_bill_id` (`bill_id`),
  KEY `bill_items_product_id` (`product_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `bill_items`
--
DROP TRIGGER IF EXISTS `tg_InsertBillItem_After`;
DELIMITER $$
CREATE TRIGGER `tg_InsertBillItem_After` AFTER INSERT ON `bill_items` FOR EACH ROW BEGIN
	UPDATE bills
    SET total=(SELECT SUM(total) FROM bill_items WHERE bill_id=new.bill_id)
    WHERE id=new.bill_id;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `tg_InsertBillItem_Before`;
DELIMITER $$
CREATE TRIGGER `tg_InsertBillItem_Before` BEFORE INSERT ON `bill_items` FOR EACH ROW BEGIN
	SELECT name, price
    INTO @name, @price
    FROM products
    WHERE id=new.product_id;
    
    SET new.product_name = @name;
    SET new.current_price = @price;
    SET new.total = new.current_price * new.quantity;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `carts`
--

DROP TABLE IF EXISTS `carts`;
CREATE TABLE IF NOT EXISTS `carts` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `total` bigint DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `carts_user_id` (`user_id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `carts`
--

INSERT INTO `carts` (`id`, `user_id`, `total`, `created_at`) VALUES
(1, 1, NULL, '2021-11-22 17:35:08');

--
-- Triggers `carts`
--
DROP TRIGGER IF EXISTS `tg_DeleteCart_Before`;
DELIMITER $$
CREATE TRIGGER `tg_DeleteCart_Before` BEFORE DELETE ON `carts` FOR EACH ROW BEGIN
	SET @id = old.id;
	IF EXISTS (SELECT id FROM cart_items WHERE cart_id=@id) THEN
        DELETE FROM cart_items
        WHERE cart_items.cart_id=old.id;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `cart_items`
--

DROP TABLE IF EXISTS `cart_items`;
CREATE TABLE IF NOT EXISTS `cart_items` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `cart_id` bigint NOT NULL,
  `product_id` bigint NOT NULL,
  `quantity` int NOT NULL DEFAULT '1',
  `price` bigint DEFAULT NULL,
  `total` bigint DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `cart_items_cart_id` (`cart_id`),
  KEY `cart_items_product_id` (`product_id`)
) ENGINE=MyISAM AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `cart_items`
--
DROP TRIGGER IF EXISTS `tg_DeleteCartItem_After`;
DELIMITER $$
CREATE TRIGGER `tg_DeleteCartItem_After` AFTER DELETE ON `cart_items` FOR EACH ROW BEGIN
	SET @cart_id=old.cart_id;
	UPDATE carts
    SET total=(SELECT SUM(total) FROM cart_items WHERE cart_id=@cart_id)
    WHERE id=@cart_id;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `tg_InsertCartItems_After`;
DELIMITER $$
CREATE TRIGGER `tg_InsertCartItems_After` AFTER INSERT ON `cart_items` FOR EACH ROW BEGIN
	SET @cart_id=new.cart_id;
	UPDATE carts
    SET total=(SELECT SUM(total) FROM cart_items WHERE cart_id=@cart_id)
    WHERE id=@cart_id;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `tg_InsertCartItems_Before`;
DELIMITER $$
CREATE TRIGGER `tg_InsertCartItems_Before` BEFORE INSERT ON `cart_items` FOR EACH ROW BEGIN
	set @product_id=new.product_id;

    SELECT price
    INTO @price
    FROM products
    WHERE products.id=@product_id
    LIMIT 1;
    
    SET new.price=@price;
    SET new.total=@price*new.quantity;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `tg_UpdateCartItems_After`;
DELIMITER $$
CREATE TRIGGER `tg_UpdateCartItems_After` AFTER UPDATE ON `cart_items` FOR EACH ROW BEGIN
	SET @cart_id=new.cart_id;
	UPDATE carts
    SET total=(SELECT SUM(total) FROM cart_items WHERE cart_id=@cart_id)
    WHERE id=@cart_id;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `tg_UpdateCartItems_Before`;
DELIMITER $$
CREATE TRIGGER `tg_UpdateCartItems_Before` BEFORE UPDATE ON `cart_items` FOR EACH ROW BEGIN   
    SET new.total=new.price*new.quantity;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
CREATE TABLE IF NOT EXISTS `categories` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `category_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `categories`
--
DROP TRIGGER IF EXISTS `tg_DeleteCategory_Before`;
DELIMITER $$
CREATE TRIGGER `tg_DeleteCategory_Before` BEFORE DELETE ON `categories` FOR EACH ROW BEGIN
	SET @id=old.id;
    IF EXISTS (SELECT id FROM products WHERE category_id=@id) THEN
        DELETE FROM products
        WHERE products.category_id=old.id;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `likes`
--

DROP TABLE IF EXISTS `likes`;
CREATE TABLE IF NOT EXISTS `likes` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `product_id` bigint NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `likes_user_id` (`user_id`),
  KEY `like_product_id` (`product_id`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `likes`
--
DROP TRIGGER IF EXISTS `tg_DeleteLike_After`;
DELIMITER $$
CREATE TRIGGER `tg_DeleteLike_After` AFTER DELETE ON `likes` FOR EACH ROW BEGIN
	set @product_id=old.product_id;
    update products
    set count_likes = (select count(id) from likes where product_id=@product_id) where products.id=@product_id;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `tg_InsertLike_After`;
DELIMITER $$
CREATE TRIGGER `tg_InsertLike_After` AFTER INSERT ON `likes` FOR EACH ROW BEGIN
	set @product_id=new.product_id;
    update products
    set count_likes = (select count(id) from likes where product_id=@product_id) where products.id=@product_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
CREATE TABLE IF NOT EXISTS `messages` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `customer_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_id` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
CREATE TABLE IF NOT EXISTS `products` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `count_likes` int DEFAULT '0',
  `category_id` bigint UNSIGNED NOT NULL,
  `price` bigint NOT NULL,
  `reviews` int DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `products_category_id` (`category_id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `products`
--
DROP TRIGGER IF EXISTS `tg_DeleteProduct_Before`;
DELIMITER $$
CREATE TRIGGER `tg_DeleteProduct_Before` BEFORE DELETE ON `products` FOR EACH ROW BEGIN
	 SET @id = old.id;
	IF EXISTS (SELECT * FROM product_images WHERE product_id=@id) THEN
    	DELETE FROM product_images
    	WHERE product_images.product_id=@id;
    END IF;
    
    IF EXISTS (SELECT * FROM cart_items WHERE product_id=@id) THEN
        DELETE FROM cart_items
        WHERE cart_items.product_id=@id;
    END IF;
    
    IF EXISTS (SELECT * FROM likes WHERE product_id=@id) THEN
        DELETE FROM likes
        WHERE likes.product_id=@id;
    END IF;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `tg_UpdateProduct_After`;
DELIMITER $$
CREATE TRIGGER `tg_UpdateProduct_After` AFTER UPDATE ON `products` FOR EACH ROW BEGIN
	SET @id = new.id;
	IF (new.price != old.price) THEN
    	IF EXISTS (SELECT id FROM cart_items WHERE product_id=@id) THEN
            UPDATE cart_items
            SET price=new.price
            WHERE product_id=@id;
    	END IF;
	END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `product_images`
--

DROP TABLE IF EXISTS `product_images`;
CREATE TABLE IF NOT EXISTS `product_images` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `product_id` bigint UNSIGNED NOT NULL,
  `image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `product_images_product_id` (`product_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'avatar-default.png',
  `status` tinyint(1) DEFAULT '0',
  `roll` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'user',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password`, `phone`, `address`, `avatar`, `status`, `code`, `created_at`) VALUES
(1, 'Admin', 'admin@admin.com', '$2y$10$XKDh3Rqvkj6oHcBqHF3Pe.sxAPp/08F0urXdYLLeIdKxHcCEDO3li', NULL, 'HCM', 'avatar-default.png', 0, '', '2021-11-19 09:41:16');

--
-- Triggers `users`
--
DROP TRIGGER IF EXISTS `tg_DeleteUser_Before`;
DELIMITER $$
CREATE TRIGGER `tg_DeleteUser_Before` BEFORE DELETE ON `users` FOR EACH ROW BEGIN
	SET @id = old.id;
    IF EXISTS (SELECT id FROM carts WHERE user_id=@id) THEN
        DELETE FROM carts
        WHERE carts.user_id=@id;
    END IF;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `tg_InsertUser_After`;
DELIMITER $$
CREATE TRIGGER `tg_InsertUser_After` AFTER INSERT ON `users` FOR EACH ROW BEGIN
	set @user_id=new.id;
    INSERT INTO carts(user_id) values (@user_id);
END
$$
DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
