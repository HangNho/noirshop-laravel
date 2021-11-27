-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Nov 26, 2021 at 10:03 AM
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
-- Database: `noirshop_laravel`
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
  `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `carts`
--

INSERT INTO `carts` (`id`, `user_id`, `total`, `created_at`) VALUES
(1, 1, NULL, '2021-11-22 17:35:08'),
(3, 3, 0, '2021-11-24 12:08:30'),
(6, 6, 0, '2021-11-24 18:17:26');

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
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `name`, `created_at`) VALUES
(2, 'Tẩy trang', '2021-11-24 15:03:34'),
(3, 'Toner/ Nước hoa hồng', '2021-11-24 15:04:30'),
(4, 'Serum - Tinh chất', '2021-11-24 15:04:30');

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
-- Table structure for table `featured_products`
--

DROP TABLE IF EXISTS `featured_products`;
CREATE TABLE IF NOT EXISTS `featured_products` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `product_id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `price` bigint NOT NULL,
  `previews` int DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `count_likes` int DEFAULT '0',
  `category_id` bigint UNSIGNED NOT NULL,
  `price` bigint NOT NULL,
  `reviews` int DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `products_category_id` (`category_id`)
) ENGINE=MyISAM AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `name`, `description`, `count_likes`, `category_id`, `price`, `reviews`, `created_at`) VALUES
(4, 'Tẩy trang L\'Oreal 400ml', '𝐍𝐔̛𝐎̛́𝐂 𝐓𝐀̂̉𝐘 𝐓𝐑𝐀𝐍𝐆 𝐋𝐎𝐑𝐄𝐀𝐋 𝐏𝐀𝐑𝐈𝐒 - Nước tẩy trang làm sạch với công nghệ độc quyền từ LOreal (NƯỚC TẨY TRANG KHÔNG CỒN - AN TOÀN CHO MỌI LOẠI DA)\r\n \r\nVới công nghệ mới nhất, nước tẩy trang L\'Oreal Paris 3-in-1 Micellar Water mang đến các tẩy trang, làm sạch, giữ ẩm và dưỡng mềm da đồng thời chỉ trong một sản phẩm. L\'Oreal Paris 3-in-1 Micellar Water giúp lấy đi sạch cặn trang điểm nhưng không làm khô da. Hơn thế, thành phần an toàn và công nghệ tiên tiến giúp da giữ nước, thông thoáng, mềm mượt.\r\n.\r\n  𝑹𝒆𝒇𝒓𝒆𝒔𝒉𝒊𝒏𝒈 𝒆𝒗𝒆𝒏 𝒇𝒐𝒓 𝒔𝒆𝒏𝒔𝒊𝒕𝒊𝒗𝒆 𝒔𝒌𝒊𝒏 (Chai xanh #nhạt): Tươi mát da. Dành cho da dầu hoặc da hỗn hợp. Phù hợp cho cả da nhạy cảm, không chứa cồn, không kích ứng da\r\n \r\n  𝑫𝒆𝒆𝒑 𝒄𝒍𝒆𝒂𝒏𝒔𝒊𝒏𝒈 𝒆𝒗𝒆𝒏 𝒇𝒐𝒓 𝒔𝒆𝒏𝒔𝒊𝒕𝒊𝒗𝒆 𝒔𝒌𝒊𝒏 (Chai xanh đậm): Làm sạch sâu. Dành cho nàng trang điểm đậm, bền màu, lâu trôi. Phù hợp cho cả da nhạy cảm, không chứa cồn, không kích ứng da\r\n \r\n𝑴𝒐𝒊𝒔𝒕𝒖𝒓𝒊𝒛𝒊𝒏𝒈 𝒆𝒗𝒆𝒏 𝒇𝒐𝒓 𝒔𝒆𝒏𝒔𝒊𝒕𝒊𝒗𝒆 𝒔𝒌𝒊𝒏 (Chai màu #hồng): Ẩm mượt da. Dành cho da khô hoặc da thường. Phù hợp cho cả da nhạy cảm, không chứa cồn, không kích ứng da.', 0, 2, 100000, NULL, '2021-11-24 15:11:19'),
(5, 'Tẩy trang Bioderma 500ml', ' 𝐍𝐔̛𝐎̛́𝐂 𝐓𝐀̂̉𝐘 𝐓𝐑𝐀𝐍𝐆 𝐁𝐈𝐎𝐃𝐄𝐑𝐌𝐀 𝟓𝟎𝟎𝐦𝐥 \r\n \r\n Bioderma Tẩy trang xứng đáng là nước tẩy trang 𝐒𝐎̂́ 𝟏 𝐓𝐇𝐄̂́ 𝐆𝐈𝐎̛́𝐈 mà chị em nên sở hữu\r\n 𝑴𝒂̀𝒖 𝒉𝒐̂̀𝒏 : D𝒂̀𝒏𝒉 𝒄𝒉𝒐 𝒅𝒂 thường 𝒌𝒉𝒐̂ 𝒗𝒂 𝒏𝒉𝒂̣𝒚 𝒄𝒂̉𝒎\r\n 𝑴𝒂̀𝒖 𝒙𝒂𝒏 : D𝒂̀𝒏𝒉 𝒄𝒉𝒐 𝒅𝒂 𝒅𝒂̂̀𝒖 𝒗𝒂̀ 𝒉𝒐̂̃𝒏 𝒉𝒐̛̣𝒑 và mụn\r\n  Thành phần chiết xuất từ dưa chuột\r\n- Không chứa xà phòng\r\n- Không chứa chất tẩy rửa\r\n- Không hương liệu\r\n- Có thể dùng tẩy trang cả vùng da mắt nhạy cảm, và em ý #an_toàn đến mức dù sau khi tẩy trang bạn vội quá k thể rửa mặt lại vs nước thì da vẫn sạch, không nhờn dính cũng không khô căng ráp.\r\n𝐕𝐚̣̂𝐲 đ𝐚̂𝐮 𝐥𝐚̀ 𝐮̛𝐮 đ𝐢𝐞̂̉𝐦 𝐜𝐡𝐮́𝐧𝐠 𝐦𝐢̀𝐧𝐡 𝐧𝐞̂𝐧 𝐜𝐡𝐨̣𝐧 𝐞𝐦 𝐚̂́𝐲\r\n𝐂𝐨̂𝐧𝐠 𝐝𝐮̣𝐧𝐠:\r\n Mascara, bụi bẩn, dầu thừa bay sạch chỉ trong vài giây.\r\n Nhẹ dịu, không có nước hoa, ít dầu, không cồn, không gây kích ứng.\r\n Không clog pores, không gây mụn, cân bằng lại làn da.\r\n Phù hợp cho mọi loại da.\r\n Tẩy trang nhanh và đơn giản.\r\n Nhiều và dùng được lâu.\r\n𝐓𝐢́𝐧𝐡 𝐚𝐧 𝐭𝐨𝐚̀𝐧: 𝐒𝐚̉𝐧 𝐩𝐡𝐚̂̉𝐦 𝐡𝐨𝐚̀𝐧 𝐭𝐨𝐚̀𝐧 𝐊𝐇𝐎̂𝐍𝐆 𝐜𝐡𝐮̛́𝐚 𝐂𝐎̂̀𝐍, 𝐌𝐔̀𝐈, 𝐏𝐀𝐑𝐀𝐁𝐄𝐍 𝐯𝐚̀ 𝐜𝐚́𝐜 𝐜𝐡𝐚̂́𝐭 𝐠𝐚̂𝐲 𝐡𝐚̣𝐢 𝐜𝐡𝐨 𝐝𝐚 𝐧𝐞̂𝐧 𝐜𝐡𝐮́𝐧𝐠 𝐭𝐚 𝐜ó thể sử dụng hàng ngày.', 0, 2, 200000, NULL, '2021-11-24 15:12:41'),
(6, 'Tẩy trang Simple 200ml', NULL, 0, 2, 300000, NULL, '2021-11-24 15:13:58'),
(7, 'Tẩy trang Centifolia 500ml', '💚Nước tẩy trang chiết xuất lá bạch quả CENTIFOLIA Micellar Water 500ml \r\n------------------------\r\n☘ Thành phần lá bạch quả chứa hợp chất flavonoides hỗ trợ thúc đẩy sự hình thành tế bào mới khỏe mạnh và giúp làm tăng độ đàn hồi cho da.\r\n☘ Vitamin E trong thành phần của CENTIFOLIA Micellar Water 500ml giúp làm dịu những vùng da kích ứng, làm mềm những vùng da khô sần, hỗ trợ bảo vệ da trước các tác nhân gây hại và giúp làm chậm tiến trình lão hóa da. \r\n☘ Sản phẩm không chứa xà phòng, không chứa cồn, không chất tạo màu, không Paraben và an toàn cho làn da khi sử dụng.\r\n☘ Sản phẩm thích hợp sử dụng cho mọi loại da, từ da hỗn hợp đến da dầu và da mụn nhạy cảm.\r\n', 0, 2, 400000, NULL, '2021-11-24 15:54:40'),
(8, 'Tẩy trang La Roche-posay 400ml', NULL, 0, 2, 150000, NULL, '2021-11-24 15:55:42'),
(9, 'Tẩy trang bí đao Cocoon 500ml', NULL, 0, 2, 210000, NULL, '2021-11-24 15:57:49'),
(10, 'Tẩy trang SVR 400ml', NULL, 0, 2, 250000, NULL, '2021-11-24 15:58:27'),
(11, 'Toner hoa cúc SNO 200ml', '💚 Nước Cân Bằng Hoa Cúc SNO Toner Calendula Herbal Phyto\r\nToner Dành Cho Cô Nàng Có Làn Da Dễ Bị Kích Ứng,Đang Bị Tổn Thương🌼 \r\n💚 Chứa 96% chiết xuất từ thiên nhiên giúp nuôi dưỡng, làm sạch, cân bằng và ngăn ngừa các vấn đề da hiệu quả đem đến làn da sáng mịn, tươi trẻ.\r\n_______\r\n🌻 Thành phần: \r\n✔️ NIACINAMIDE & ADENOSINE: làm trắng sáng và chống nhăn da phổ biến vô cùng hiệu quả\r\n✔️ Chiết xuất hoa cúc Calendula nguyên chất (19.4mg), CÁNH HOA CÚC TƯƠI: dưỡng ẩm, làm mềm da, kháng khuẩn, giảm tác nhân kích ứng da, dịu nốt mụn\r\n✔️ Chiết xuất cúc La Mã: giảm sưng tấy, nhanh liền, sẹo, kháng viêm\r\n✔️ Chiết xuất các loại thảo mộc khác như: xô thơm, bạch đầu ông, xuyên tiêu, oải hương, cam thảo, vỏ cây liễu trắng, hương thảo: cân bằng da, điều tiết bã nhờn và kháng khuẩn, giảm mụn và xoa dịu làn da nhạy cảm\r\n✔️ Chiết xuất keo ong: cho làn da căng bóng\r\n✔️ Chiết xuất rau má, lá olive, trà xanh: dưỡng ẩm, hỗ trợ phục hồi giúp bề mặt da trơn láng.\r\n✔️ Chứa EGF gồm các polypeptide và oligopeptide: giúp khôi phục, sữa hỗ trợ điều trị làn da, tăng sinh collagen đem đến làn da mềm mịn, căng mượt và giảm thiểu nếp nhăn\r\n_______\r\n😍 Hướng dẫn sử dụng\r\n– Dùng sữa rửa mặt để làm sạch\r\n– Đổ 1 lượng sản phẩm ra bông tẩy trang hoặc lòng bàn tay rồi thoa đều lên mặt\r\n– Có thể sử dụng làm lotion mask\r\n– Chiết ra và sử dụng như 1 loại mist dưỡng ẩm.\r\n', 0, 3, 120000, NULL, '2021-11-24 15:59:35'),
(12, 'Toner Mamonde Diếp Cá 250ml', NULL, 0, 3, 230000, NULL, '2021-11-24 16:00:07'),
(13, 'Serum Estee Lauder Advaned Night Repair', '✨ Serum Estee Lauder Advaned Night Repair - cứu tinh cho làn da lão hóa‼\r\n✔️ SP #CHỐNG_LÃO_HÓA được yêu thích nhất tại Beauty Garden.\r\n✔️ Không chỉ #XÓA_MỜ_NẾP_NHĂN mà còn giúp cho làn da của bạn luôn #CĂNG_MỊN sáng hồng.\r\n----------------------\r\n➡️ Estee Lauder Advaned Night Repair có mặt trong hầu hết các bảng xếp hạng uy tín nhất trong hạng mục tinh chất chống lão hoá và đã trở thành sản phẩm biểu tượng của Estee Lauder suốt 30 năm qua.\r\n\r\n➡️ Huyết thanh khôi phục tuổi thanh xuân cho làn da. Khả năng chống lại các nếp nhăn, điều trị khô da, da mất nước, xỉn màu hay da nhìn thiếu sức sống.\r\n\r\n➡️ Da bạn sẽ được F5 1 cách đáng kể nếu kiên trì dùng 1-2 tuần. Rất nhiều người sử dụng Estee Lauder Advanced Night Repair đã bị bất ngờ bởi tác dụng thần kỳ chỉ trong 4 tuần sử dụng: Khuôn mặt sáng lên trông thấy, quầng thâm quanh mắt biến mất, các vết nhăn mờ đi đáng kể.\r\n\r\n[ #CÁCH_SỬ_DỤNG ]\r\n- Dùng vào buổi tối, sau khi rửa mặt sạch, dùng nước hoa hồng rồi thoa serum, sau đó thoa kem dưỡng.\r\n', 0, 4, 250000, NULL, '2021-11-24 16:03:07'),
(14, 'Serum The Ordinary Hyaluronic Acid 2% + B5', '✨ Serum CẤP_ẨM 💦 PHỤC_HỒI_DA thần kỳ The Ordinary 💦\r\n✔ 1 Siêu phẩm đến từ nhãn hiệu The_Ordinary - cực kỳ chất lượng nhưng giá thành lại rất rẻ 💯\r\n✔ Thành phần 2% Hyaluronic Acid đem lại hiệu quả cấp nước vượt trội, giúp làn da đủ ẩm, săn chắc và khỏe mạnh\r\n✔ Thành phần B5 hỗ trợ làm dịu và phục hồi da tối ưu \r\n--------\r\n#CÔNG_DỤNG:\r\n💦Giữ ẩm: ổn định chức năng bảo vệ của da, khóa ẩm tốt nhờ giữ không cho nước trong da thoát ra ngoài. Qua đó giúp da mềm mại và tăng độ đàn hồi, cải thiện làn da khô ráp. Vì vậy B5 là sự lựa chọn hàng đầu cho bạn nào da yếu, bị nhiều vấn đề do lớp màng bảo vệ da bị hỏng hoặc da nứt nẻ thì có thể dùng nhé.\r\n\r\n☄️Vitamin B5 hoạt động như chất bảo vệ và làm lành da tự nhiên: giúp giảm ngứa, sưng đỏ, phục hồi da sau lăn kim, trị mụn giúp đẩy nhanh quá trình lành vết thương, tăng độ bền vững cho các mô liên kết sẹo.\r\n\r\n☄️Vitamin B5 có công dụng hiệu quả trong việc xoa dịu làn da bị kích ứng. Đồng thời phục hồi lớp biểu bì da bằng cách cung cấp oxy và chất béo cho da. Ngoài ra, đã có chứng minh cho rằng sử dụng Vitamin B5 liên tục trong 8 tuần có thể giúp giảm mụn đến 50%.\r\n\r\n🌞Điểm vượt trội của Serum The Ordinary Hyaluronic Acid 2% + B5 theo hãng quảng cáo là chứa phân tử HA nhỏ, nhỏ vừa, và to cho hiệu quả dưỡng ẩm đa chiều và ngấm sâu. Không phải sản phẩm nào chứa HA cũng hiệu quả bởi mức độ phân tử sẽ quyết định mức độ thẩm thấu vào da.\r\n------------\r\nCÁCH SỬ DỤNG:\r\n- Sử dụng ngày 1-2 lần vào buổi sáng - tối trước khi ngủ\r\n- Bôi khoảng 3-5 giọt serum lên mặt và cổ sau khi rửa sạch.\r\n', 0, 4, 500000, NULL, '2021-11-24 16:04:02');

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
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'avatar-default.png',
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `roll` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'user',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `remember_token` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password`, `avatar`, `email_verified_at`, `roll`, `code`, `remember_token`, `created_at`) VALUES
(1, 'Admin', 'admin@admin.com', '$2y$10$McquWJ0ElM1jKwXovpIVueUiGYlaMbl49PqlMv.FciuKwdkeObHD2', 'avatar-default.png', '0000-00-00 00:00:00', 'admin', '', NULL, '2021-11-19 09:41:16'),
(3, 'Admin 2', 'admin2@admin.com', '$2y$10$McquWJ0ElM1jKwXovpIVueUiGYlaMbl49PqlMv.FciuKwdkeObHD2', 'avatar-default.png', NULL, 'admin', '', NULL, '2021-11-24 12:08:30'),
(6, 'user', 'user@user.com', '$2y$10$Ju6M6MiyI43YNIHWzL5aTO2EAABFp0B3F9miiegLF1A2QxLJFU.Di', 'avatar-default.png', NULL, 'user', NULL, NULL, '2021-11-24 11:17:26');

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
