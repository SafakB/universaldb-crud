
SET FOREIGN_KEY_CHECKS=0;
-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Anamakine: 127.0.0.1:3307
-- Üretim Zamanı: 25 Tem 2025, 10:41:24
-- Sunucu sürümü: 11.5.2-MariaDB
-- PHP Sürümü: 8.1.31

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Veritabanı: `bhaber`
--

DELIMITER $$
--
-- Yordamlar
--
DROP PROCEDURE IF EXISTS `AddArticleCategory`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddArticleCategory` (IN `p_article_id` INT, IN `p_category_id` INT, IN `p_is_primary` BOOLEAN)   BEGIN
    DECLARE existing_count INT DEFAULT 0;
    
    -- Kategori zaten ekli mi kontrol et
    SELECT COUNT(*) INTO existing_count
    FROM article_categories 
    WHERE article_id = p_article_id AND category_id = p_category_id;
    
    IF existing_count = 0 THEN
        -- Eğer ana kategori olarak işaretleniyorsa, diğer ana kategori işaretlerini kaldır
        IF p_is_primary = TRUE THEN
            UPDATE article_categories 
            SET is_primary = FALSE 
            WHERE article_id = p_article_id;
            
            -- Ana kategoriyi articles tablosunda da güncelle
            UPDATE articles 
            SET primary_category_id = p_category_id 
            WHERE id = p_article_id;
        END IF;
        
        INSERT INTO article_categories (article_id, category_id, is_primary) 
        VALUES (p_article_id, p_category_id, p_is_primary);
    END IF;
END$$

DROP PROCEDURE IF EXISTS `GetArticlesByCategory`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetArticlesByCategory` (IN `p_category_id` INT, IN `p_limit` INT, IN `p_offset` INT)   BEGIN
    SELECT DISTINCT
        a.id, a.title, a.slug, a.summary, a.featured_image,
        a.published_at, a.view_count, a.comment_count,
        au.display_name as author_name,
        pc.name as primary_category_name
    FROM articles a
    JOIN authors au ON a.author_id = au.id
    JOIN categories pc ON a.primary_category_id = pc.id
    JOIN article_categories ac ON a.id = ac.article_id
    WHERE ac.category_id = p_category_id
    AND a.status = 'published'
    AND (a.published_at IS NULL OR a.published_at <= NOW())
    ORDER BY a.published_at DESC
    LIMIT p_limit OFFSET p_offset;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `articles`
--

DROP TABLE IF EXISTS `articles`;
CREATE TABLE IF NOT EXISTS `articles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `summary` text DEFAULT NULL,
  `content` longtext NOT NULL,
  `featured_image` varchar(255) DEFAULT NULL,
  `author_id` int(11) NOT NULL,
  `primary_category_id` int(11) NOT NULL,
  `status` enum('draft','published','archived','scheduled') DEFAULT 'draft',
  `is_featured` tinyint(1) DEFAULT 0,
  `is_breaking` tinyint(1) DEFAULT 0,
  `view_count` int(11) DEFAULT 0,
  `like_count` int(11) DEFAULT 0,
  `comment_count` int(11) DEFAULT 0,
  `published_at` timestamp NULL DEFAULT NULL,
  `scheduled_at` timestamp NULL DEFAULT NULL,
  `meta_title` varchar(200) DEFAULT NULL,
  `meta_description` text DEFAULT NULL,
  `meta_keywords` varchar(500) DEFAULT NULL,
  `reading_time` int(11) DEFAULT 0,
  `word_count` int(11) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`),
  KEY `idx_slug` (`slug`),
  KEY `idx_author` (`author_id`),
  KEY `idx_primary_category` (`primary_category_id`),
  KEY `idx_status` (`status`),
  KEY `idx_published` (`published_at`),
  KEY `idx_featured` (`is_featured`),
  KEY `idx_breaking` (`is_breaking`),
  KEY `idx_views` (`view_count`),
  KEY `idx_status_published` (`status`,`published_at`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Tablo döküm verisi `articles`
--

INSERT INTO `articles` (`id`, `title`, `slug`, `summary`, `content`, `featured_image`, `author_id`, `primary_category_id`, `status`, `is_featured`, `is_breaking`, `view_count`, `like_count`, `comment_count`, `published_at`, `scheduled_at`, `meta_title`, `meta_description`, `meta_keywords`, `reading_time`, `word_count`, `created_at`, `updated_at`) VALUES
(1, 'Mahkeme yeni bir karar açıkladı', 'makale-1', 'Mahkeme tarafından açıklanan yeni karar gündemde büyük ses getirdi.', 'Olayların gelişimiyle ilgili detaylar şu şekilde...', '/uploads/image_1.jpg', 2, 4, 'published', 0, 1, 601, 142, 36, '2025-06-08 22:01:43', NULL, 'Mahkeme yeni bir karar açıkladı - Haber Sitesi', 'Haberin detayı ve etkileri hakkında bilgiler...', 'yeni,karar,gündem,mahkeme,açıklama', 2, 553, '2025-07-24 07:57:47', '2025-07-24 08:14:32'),
(2, 'Teknoloji devi yeni ürününü tanıttı', 'makale-2', 'Yeni ürün tanıtımı teknoloji dünyasında heyecan yarattı.', 'Tanıtım sırasında özellikler şöyle özetlendi...', '/uploads/image_2.jpg', 1, 3, 'published', 0, 0, 145, 43, 13, '2025-06-18 22:01:43', NULL, 'Teknoloji devi yeni ürününü tanıttı - Haber Sitesi', 'Ürün detayları ve değerlendirmeler burada...', 'teknoloji,yeni,ürün,özellik,inceleme', 4, 631, '2025-07-24 07:57:47', '2025-07-24 07:57:47'),
(3, 'Spor dünyası bu transferi konuşuyor', 'makale-3', 'Beklenen transfer sonunda gerçekleşti.', 'Transferin perde arkası detaylar haberde...', '/uploads/image_3.jpg', 4, 2, 'published', 1, 1, 710, 292, 49, '2025-07-03 22:01:43', NULL, 'Spor dünyası bu transferi konuşuyor - Haber Sitesi', 'Transfer detayları ve kulis bilgileri...', 'spor,transfer,futbol,gündem,kulis', 2, 679, '2025-07-24 07:57:47', '2025-07-24 07:57:47'),
(4, 'Ekonomide yeni beklentiler oluştu', 'makale-4', 'Piyasalardaki hareketlilik beklentileri artırdı.', 'Uzmanlar gelişmeleri şöyle yorumladı...', '/uploads/image_4.jpg', 2, 4, 'published', 0, 0, 637, 171, 25, '2025-06-25 22:01:43', NULL, 'Ekonomide yeni beklentiler oluştu - Haber Sitesi', 'Ekonomik gelişmelerin etkileri...', 'ekonomi,piyasa,analiz,beklenti,döviz', 4, 846, '2025-07-24 07:57:47', '2025-07-24 07:57:47'),
(5, 'Yeni sergi sanatseverlerle buluştu', 'makale-5', 'Sanatseverler için kaçırılmayacak bir sergi açıldı.', 'Sergide yer alan eserler dikkat çekiyor...', '/uploads/image_5.jpg', 3, 5, 'published', 1, 1, 431, 212, 8, '2025-06-16 22:01:43', NULL, 'Yeni sergi sanatseverlerle buluştu - Haber Sitesi', 'Sanatın farklı yönlerini keşfedin...', 'sergi,sanat,kültür,etkinlik,görsel', 8, 1050, '2025-07-24 07:57:47', '2025-07-24 08:14:32'),
(6, 'Yeni yasa teklifi mecliste', 'makale-6', 'Görüşülen yeni yasa teklifinin detayları netleşti.', 'Tasarıya göre birçok değişiklik yapılması planlanıyor...', '/uploads/image_6.jpg', 3, 1, 'published', 0, 0, 392, 21, 13, '2025-05-28 22:01:43', NULL, 'Yeni yasa teklifi mecliste - Haber Sitesi', 'Meclisteki gelişmeler ve tepkiler...', 'yasa,meclis,gündem,değişiklik,kanun', 6, 744, '2025-07-24 07:57:47', '2025-07-24 07:57:47'),
(7, 'Kültürel miras restore ediliyor', 'makale-7', 'Uzun süredir beklenen restorasyon çalışmaları başladı.', 'Projede yer alan yapılar tek tek elden geçiriliyor...', '/uploads/image_7.jpg', 2, 5, 'published', 1, 0, 87, 57, 7, '2025-07-04 22:01:43', NULL, 'Kültürel miras restore ediliyor - Haber Sitesi', 'Tarihi yapıların korunması adına önemli adım...', 'restorasyon,kültür,miraz,tarih,proje', 6, 1087, '2025-07-24 07:57:47', '2025-07-24 07:57:47'),
(8, 'Teknoloji fuarında ilginç gelişmeler', 'makale-8', 'Fuar boyunca birçok yenilik tanıtıldı.', 'Katılımcılar memnun kaldı...', '/uploads/image_8.jpg', 1, 3, 'published', 1, 1, 984, 112, 21, '2025-06-09 22:01:43', NULL, 'Teknoloji fuarında ilginç gelişmeler - Haber Sitesi', 'Yeni teknolojiler ve trendler...', 'teknoloji,fuar,yenilik,buluş,katılım', 4, 1091, '2025-07-24 07:57:47', '2025-07-24 07:57:47'),
(9, 'Döviz kurlarında sert dalgalanma', 'makale-9', 'Son günlerde dövizde hareketlilik yaşanıyor.', 'Yatırımcılar için önemli ipuçları verildi...', '/uploads/image_9.jpg', 5, 4, 'published', 0, 1, 417, 288, 7, '2025-06-02 22:01:43', NULL, 'Döviz kurlarında sert dalgalanma - Haber Sitesi', 'Ekonomide dalgalı seyrin etkileri...', 'döviz,kurlar,ekonomi,piyasa,faiz', 4, 1037, '2025-07-24 07:57:47', '2025-07-24 08:14:32'),
(10, 'Yeni röportaj serisi başlıyor', 'makale-10', 'Röportaj serisinin ilk bölümü yayınlandı.', 'Yazarlar merak edilenleri yanıtlıyor...', '/uploads/image_10.jpg', 5, 1, 'published', 0, 1, 389, 47, 26, '2025-06-16 22:01:43', NULL, 'Yeni röportaj serisi başlıyor - Haber Sitesi', 'Merak edilen konuların perde arkası...', 'röportaj,gündem,yazar,seri,konu', 2, 224, '2025-07-24 07:57:47', '2025-07-24 08:14:32');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `article_categories`
--

DROP TABLE IF EXISTS `article_categories`;
CREATE TABLE IF NOT EXISTS `article_categories` (
  `article_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `is_primary` tinyint(1) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`article_id`,`category_id`),
  KEY `idx_article` (`article_id`),
  KEY `idx_category` (`category_id`),
  KEY `idx_primary` (`is_primary`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Tablo döküm verisi `article_categories`
--

INSERT INTO `article_categories` (`article_id`, `category_id`, `is_primary`, `created_at`) VALUES
(1, 1, 0, '2025-07-24 08:04:23'),
(1, 4, 1, '2025-07-24 08:04:23'),
(2, 3, 1, '2025-07-24 08:04:23'),
(2, 5, 0, '2025-07-24 08:04:23'),
(3, 1, 0, '2025-07-24 08:04:23'),
(3, 2, 1, '2025-07-24 08:04:23'),
(4, 2, 0, '2025-07-24 08:04:23'),
(4, 4, 1, '2025-07-24 08:04:23'),
(5, 3, 0, '2025-07-24 08:04:23'),
(5, 5, 1, '2025-07-24 08:04:23'),
(6, 1, 1, '2025-07-24 08:04:23'),
(6, 3, 0, '2025-07-24 08:04:23'),
(7, 2, 0, '2025-07-24 08:04:23'),
(7, 5, 1, '2025-07-24 08:04:23'),
(8, 3, 1, '2025-07-24 08:04:23'),
(8, 4, 0, '2025-07-24 08:04:23'),
(9, 4, 1, '2025-07-24 08:04:23'),
(9, 5, 0, '2025-07-24 08:04:23'),
(10, 1, 1, '2025-07-24 08:04:23'),
(10, 2, 0, '2025-07-24 08:04:23');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `article_likes`
--

DROP TABLE IF EXISTS `article_likes`;
CREATE TABLE IF NOT EXISTS `article_likes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `article_id` int(11) NOT NULL,
  `visitor_ip` varchar(45) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_article_ip` (`article_id`,`visitor_ip`),
  KEY `idx_article` (`article_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Tetikleyiciler `article_likes`
--
DROP TRIGGER IF EXISTS `decrease_article_like_count`;
DELIMITER $$
CREATE TRIGGER `decrease_article_like_count` AFTER DELETE ON `article_likes` FOR EACH ROW BEGIN
    UPDATE articles 
    SET like_count = like_count - 1 
    WHERE id = OLD.article_id;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `update_article_like_count`;
DELIMITER $$
CREATE TRIGGER `update_article_like_count` AFTER INSERT ON `article_likes` FOR EACH ROW BEGIN
    UPDATE articles 
    SET like_count = like_count + 1 
    WHERE id = NEW.article_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `article_tags`
--

DROP TABLE IF EXISTS `article_tags`;
CREATE TABLE IF NOT EXISTS `article_tags` (
  `article_id` int(11) NOT NULL,
  `tag_id` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`article_id`,`tag_id`),
  KEY `idx_article` (`article_id`),
  KEY `idx_tag` (`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Tablo döküm verisi `article_tags`
--

INSERT INTO `article_tags` (`article_id`, `tag_id`, `created_at`) VALUES
(1, 2, '2025-07-24 08:04:31'),
(1, 4, '2025-07-24 08:04:31'),
(2, 1, '2025-07-24 08:04:31'),
(2, 3, '2025-07-24 08:04:31'),
(2, 4, '2025-07-24 08:04:31'),
(3, 1, '2025-07-24 08:04:31'),
(3, 2, '2025-07-24 08:04:31'),
(4, 2, '2025-07-24 08:04:31'),
(4, 3, '2025-07-24 08:04:31'),
(5, 3, '2025-07-24 08:04:31'),
(5, 4, '2025-07-24 08:04:31'),
(6, 1, '2025-07-24 08:04:31'),
(6, 4, '2025-07-24 08:04:31'),
(7, 2, '2025-07-24 08:04:31'),
(7, 3, '2025-07-24 08:04:31'),
(8, 1, '2025-07-24 08:04:31'),
(8, 2, '2025-07-24 08:04:31'),
(8, 4, '2025-07-24 08:04:31'),
(9, 3, '2025-07-24 08:04:31'),
(9, 4, '2025-07-24 08:04:31'),
(10, 1, '2025-07-24 08:04:31'),
(10, 3, '2025-07-24 08:04:31');

--
-- Tetikleyiciler `article_tags`
--
DROP TRIGGER IF EXISTS `update_tag_usage_delete`;
DELIMITER $$
CREATE TRIGGER `update_tag_usage_delete` AFTER DELETE ON `article_tags` FOR EACH ROW BEGIN
    UPDATE tags 
    SET usage_count = usage_count - 1 
    WHERE id = OLD.tag_id;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `update_tag_usage_insert`;
DELIMITER $$
CREATE TRIGGER `update_tag_usage_insert` AFTER INSERT ON `article_tags` FOR EACH ROW BEGIN
    UPDATE tags 
    SET usage_count = usage_count + 1 
    WHERE id = NEW.tag_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `article_views`
--

DROP TABLE IF EXISTS `article_views`;
CREATE TABLE IF NOT EXISTS `article_views` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `article_id` int(11) NOT NULL,
  `visitor_ip` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `referer` varchar(500) DEFAULT NULL,
  `viewed_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_article` (`article_id`),
  KEY `idx_viewed_at` (`viewed_at`),
  KEY `idx_article_ip` (`article_id`,`visitor_ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Tetikleyiciler `article_views`
--
DROP TRIGGER IF EXISTS `update_article_view_count`;
DELIMITER $$
CREATE TRIGGER `update_article_view_count` AFTER INSERT ON `article_views` FOR EACH ROW BEGIN
    UPDATE articles 
    SET view_count = view_count + 1 
    WHERE id = NEW.article_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `authors`
--

DROP TABLE IF EXISTS `authors`;
CREATE TABLE IF NOT EXISTS `authors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `display_name` varchar(100) DEFAULT NULL,
  `bio` text DEFAULT NULL,
  `avatar` varchar(255) DEFAULT NULL,
  `role` enum('admin','editor','author','contributor') DEFAULT 'author',
  `is_active` tinyint(1) DEFAULT 1,
  `email_verified` tinyint(1) DEFAULT 0,
  `last_login` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_username` (`username`),
  KEY `idx_email` (`email`),
  KEY `idx_role` (`role`),
  KEY `idx_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------
-- Gerekli authors verisi eklendi
INSERT INTO authors (id, username, email, password_hash, first_name, last_name)
VALUES
(1, 'user1', 'user1@example.com', 'pass', 'User', 'One'),
(2, 'user2', 'user2@example.com', 'pass', 'User', 'Two'),
(3, 'user3', 'user3@example.com', 'pass', 'User', 'Three'),
(4, 'user4', 'user4@example.com', 'pass', 'User', 'Four'),
(5, 'user5', 'user5@example.com', 'pass', 'User', 'Five');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `categories`
--

DROP TABLE IF EXISTS `categories`;
CREATE TABLE IF NOT EXISTS `categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `slug` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `sort_order` int(11) DEFAULT 0,
  `is_active` tinyint(1) DEFAULT 1,
  `meta_title` varchar(200) DEFAULT NULL,
  `meta_description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`),
  KEY `idx_parent_id` (`parent_id`),
  KEY `idx_slug` (`slug`),
  KEY `idx_active_sort` (`is_active`,`sort_order`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Tablo döküm verisi `categories`
--

INSERT INTO `categories` (`id`, `name`, `slug`, `description`, `parent_id`, `sort_order`, `is_active`, `meta_title`, `meta_description`, `created_at`, `updated_at`) VALUES
(1, 'Gündem', 'gundem', 'Güncel haberler ve olaylar', NULL, 0, 1, NULL, NULL, '2025-07-23 15:39:31', '2025-07-23 15:39:31'),
(2, 'Spor', 'spor', 'Spor haberleri', NULL, 0, 1, NULL, NULL, '2025-07-23 15:39:31', '2025-07-23 15:39:31'),
(3, 'Teknoloji', 'teknoloji', 'Teknoloji ve bilim haberleri', NULL, 0, 1, NULL, NULL, '2025-07-23 15:39:31', '2025-07-23 15:39:31'),
(4, 'Ekonomi', 'ekonomi', 'Ekonomi ve finans haberleri', NULL, 0, 1, NULL, NULL, '2025-07-23 15:39:31', '2025-07-23 15:39:31'),
(5, 'Kültür-Sanat', 'kultur-sanat', 'Kültür ve sanat haberleri', NULL, 0, 1, NULL, NULL, '2025-07-23 15:39:31', '2025-07-23 15:39:31');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `comments`
--

DROP TABLE IF EXISTS `comments`;
CREATE TABLE IF NOT EXISTS `comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `article_id` int(11) NOT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `author_name` varchar(100) NOT NULL,
  `author_email` varchar(100) NOT NULL,
  `author_website` varchar(255) DEFAULT NULL,
  `author_ip` varchar(45) DEFAULT NULL,
  `content` text NOT NULL,
  `status` enum('pending','approved','rejected','spam') DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_article` (`article_id`),
  KEY `idx_parent` (`parent_id`),
  KEY `idx_status` (`status`),
  KEY `idx_created` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Tablo döküm verisi `comments`
--

INSERT INTO `comments` (`id`, `article_id`, `parent_id`, `author_name`, `author_email`, `author_website`, `author_ip`, `content`, `status`, `created_at`, `updated_at`) VALUES
(1, 6, NULL, 'Muhammed Tetik', 'sevimliademoglu@selin.org', 'http://www.okumus.org/', '129.43.108.195', 'Politika önemli çünkü seçim süreci başladı.', 'pending', '2025-06-27 22:01:43', '2025-06-27 22:01:43'),
(2, 9, NULL, 'Abdullah Ertürk', 'yildizkuzey@yahoo.com', 'http://www.arslan.net/', '9.48.168.191', 'Ekonomi verileri hakkında netlik oluşmadı.', 'approved', '2025-06-28 22:01:43', '2025-06-28 22:01:43'),
(3, 1, NULL, 'Nihat Gür', 'ozgehan@gmail.com', 'https://www.bulut.org/', '231.128.222.153', 'Yeni düzenlemeler halkta karışıklık yarattı.', 'pending', '2025-06-22 22:01:43', '2025-06-22 22:01:43'),
(4, 2, NULL, 'Emrah Taş', 'bahadirmehmet@turk.net', 'https://www.akyol.com.tr/', '173.22.117.24', 'Teknolojik gelişmeler hız kesmeden devam ediyor.', 'rejected', '2025-07-11 22:01:43', '2025-07-11 22:01:43'),
(5, 5, NULL, 'Hatice Kaya', 'meltemdogan@hotmail.com', 'http://www.yamanlar.org/', '96.61.187.123', 'Kültürel etkinlikler desteklenmeli.', 'approved', '2025-06-23 22:01:43', '2025-06-23 22:01:43'),
(6, 10, NULL, 'Murat Şahin', 'kaan.akyüz@hotmail.com', 'https://www.kutlu.com/', '19.147.34.236', 'Röportaj çok başarılıydı.', 'approved', '2025-06-30 22:01:43', '2025-06-30 22:01:43'),
(7, 10, 5, 'Selin Uçar', 'asliinan@hotmail.com', 'https://www.bilge.org/', '45.164.233.188', 'Kesinlikle katılıyorum.', 'approved', '2025-07-10 22:01:43', '2025-07-10 22:01:43'),
(8, 9, 2, 'Deniz Güler', 'cihansinan@gmail.com', 'https://www.cetin.net/', '55.177.21.13', 'Bu yoruma tamamen katılıyorum.', 'approved', '2025-07-08 22:01:43', '2025-07-08 22:01:43'),
(9, 3, 4, 'Hüseyin Can', 'melikeselcuk@hotmail.com', 'http://www.özkan.org/', '241.108.25.103', 'Ek bilgiler çok faydalı.', 'pending', '2025-07-03 22:01:43', '2025-07-03 22:01:43'),
(10, 1, 6, 'Zeynep Acar', 'beyza.aydin@yahoo.com', 'http://www.oztürk.org/', '204.151.173.8', 'Bence biraz daha detay gerekirdi.', 'approved', '2025-07-07 22:01:43', '2025-07-07 22:01:43');

--
-- Tetikleyiciler `comments`
--
DROP TRIGGER IF EXISTS `update_comment_count_insert`;
DELIMITER $$
CREATE TRIGGER `update_comment_count_insert` AFTER INSERT ON `comments` FOR EACH ROW BEGIN
    IF NEW.status = 'approved' THEN
        UPDATE articles 
        SET comment_count = comment_count + 1 
        WHERE id = NEW.article_id;
    END IF;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `update_comment_count_update`;
DELIMITER $$
CREATE TRIGGER `update_comment_count_update` AFTER UPDATE ON `comments` FOR EACH ROW BEGIN
    IF OLD.status != NEW.status THEN
        IF NEW.status = 'approved' AND OLD.status != 'approved' THEN
            UPDATE articles 
            SET comment_count = comment_count + 1 
            WHERE id = NEW.article_id;
        ELSEIF OLD.status = 'approved' AND NEW.status != 'approved' THEN
            UPDATE articles 
            SET comment_count = comment_count - 1 
            WHERE id = NEW.article_id;
        END IF;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `contact_messages`
--

DROP TABLE IF EXISTS `contact_messages`;
CREATE TABLE IF NOT EXISTS `contact_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `subject` varchar(200) NOT NULL,
  `message` text NOT NULL,
  `status` enum('unread','read','replied') DEFAULT 'unread',
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `media`
--

DROP TABLE IF EXISTS `media`;
CREATE TABLE IF NOT EXISTS `media` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `filename` varchar(255) NOT NULL,
  `original_filename` varchar(255) NOT NULL,
  `mime_type` varchar(100) NOT NULL,
  `file_size` int(11) NOT NULL,
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `alt_text` varchar(255) DEFAULT NULL,
  `caption` text DEFAULT NULL,
  `file_path` varchar(500) NOT NULL,
  `uploaded_by` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_mime_type` (`mime_type`),
  KEY `idx_uploaded_by` (`uploaded_by`),
  KEY `idx_filename` (`filename`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Görünüm yapısı durumu `published_articles`
-- (Asıl görünüm için aşağıya bakın)
--
DROP VIEW IF EXISTS `published_articles`;
CREATE TABLE IF NOT EXISTS `published_articles` (
`id` int(11)
,`title` varchar(255)
,`slug` varchar(255)
,`summary` text
,`content` longtext
,`featured_image` varchar(255)
,`author_id` int(11)
,`primary_category_id` int(11)
,`status` enum('draft','published','archived','scheduled')
,`is_featured` tinyint(1)
,`is_breaking` tinyint(1)
,`view_count` int(11)
,`like_count` int(11)
,`comment_count` int(11)
,`published_at` timestamp
,`scheduled_at` timestamp
,`meta_title` varchar(200)
,`meta_description` text
,`meta_keywords` varchar(500)
,`reading_time` int(11)
,`word_count` int(11)
,`created_at` timestamp
,`updated_at` timestamp
,`author_name` varchar(100)
,`primary_category_name` varchar(100)
,`primary_category_slug` varchar(100)
,`all_categories` mediumtext
,`all_category_slugs` mediumtext
);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `settings`
--

DROP TABLE IF EXISTS `settings`;
CREATE TABLE IF NOT EXISTS `settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text DEFAULT NULL,
  `setting_type` enum('string','integer','boolean','json') DEFAULT 'string',
  `description` text DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `setting_key` (`setting_key`),
  KEY `idx_key` (`setting_key`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Tablo döküm verisi `settings`
--

INSERT INTO `settings` (`id`, `setting_key`, `setting_value`, `setting_type`, `description`, `updated_at`) VALUES
(1, 'site_title', 'Haber Sitesi', 'string', 'Site başlığı', '2025-07-23 15:39:32'),
(2, 'site_description', 'Güncel haberler ve analizler', 'string', 'Site açıklaması', '2025-07-23 15:39:32'),
(3, 'articles_per_page', '10', 'integer', 'Sayfa başına haber sayısı', '2025-07-23 15:39:32'),
(4, 'comments_enabled', 'true', 'boolean', 'Yorumlar aktif mi', '2025-07-23 15:39:32'),
(5, 'auto_approve_comments', 'false', 'boolean', 'Yorumlar otomatik onaylansın mı', '2025-07-23 15:39:32');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tags`
--

DROP TABLE IF EXISTS `tags`;
CREATE TABLE IF NOT EXISTS `tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `slug` varchar(50) NOT NULL,
  `usage_count` int(11) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `slug` (`slug`),
  KEY `idx_slug` (`slug`),
  KEY `idx_usage_count` (`usage_count`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Tablo döküm verisi `tags`
--

INSERT INTO `tags` (`id`, `name`, `slug`, `usage_count`, `created_at`) VALUES
(1, 'breaking', 'breaking', 5, '2025-07-23 15:39:32'),
(2, 'önemli', 'onemli', 5, '2025-07-23 15:39:32'),
(3, 'analiz', 'analiz', 6, '2025-07-23 15:39:32'),
(4, 'röportaj', 'roportaj', 6, '2025-07-23 15:39:32');

-- --------------------------------------------------------

--
-- Görünüm yapısı `published_articles`
--
DROP TABLE IF EXISTS `published_articles`;

DROP VIEW IF EXISTS `published_articles`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `published_articles`  AS SELECT `a`.`id` AS `id`, `a`.`title` AS `title`, `a`.`slug` AS `slug`, `a`.`summary` AS `summary`, `a`.`content` AS `content`, `a`.`featured_image` AS `featured_image`, `a`.`author_id` AS `author_id`, `a`.`primary_category_id` AS `primary_category_id`, `a`.`status` AS `status`, `a`.`is_featured` AS `is_featured`, `a`.`is_breaking` AS `is_breaking`, `a`.`view_count` AS `view_count`, `a`.`like_count` AS `like_count`, `a`.`comment_count` AS `comment_count`, `a`.`published_at` AS `published_at`, `a`.`scheduled_at` AS `scheduled_at`, `a`.`meta_title` AS `meta_title`, `a`.`meta_description` AS `meta_description`, `a`.`meta_keywords` AS `meta_keywords`, `a`.`reading_time` AS `reading_time`, `a`.`word_count` AS `word_count`, `a`.`created_at` AS `created_at`, `a`.`updated_at` AS `updated_at`, `au`.`display_name` AS `author_name`, `pc`.`name` AS `primary_category_name`, `pc`.`slug` AS `primary_category_slug`, group_concat(`c`.`name` order by `c`.`name` ASC separator ', ') AS `all_categories`, group_concat(`c`.`slug` order by `c`.`slug` ASC separator ',') AS `all_category_slugs` FROM ((((`articles` `a` join `authors` `au` on(`a`.`author_id` = `au`.`id`)) join `categories` `pc` on(`a`.`primary_category_id` = `pc`.`id`)) left join `article_categories` `ac` on(`a`.`id` = `ac`.`article_id`)) left join `categories` `c` on(`ac`.`category_id` = `c`.`id`)) WHERE `a`.`status` = 'published' AND (`a`.`published_at` is null OR `a`.`published_at` <= current_timestamp()) GROUP BY `a`.`id`, `au`.`display_name`, `pc`.`name`, `pc`.`slug` ;

--
-- Dökümü yapılmış tablolar için indeksler
--

--
-- Tablo için indeksler `articles`
--
ALTER TABLE `articles` ADD FULLTEXT KEY `idx_search` (`title`,`summary`,`content`);

--
-- Dökümü yapılmış tablolar için kısıtlamalar
--

--
-- Tablo kısıtlamaları `articles`
--
ALTER TABLE `articles`
  ADD CONSTRAINT `fk_articles_author` FOREIGN KEY (`author_id`) REFERENCES `authors` (`id`),
  ADD CONSTRAINT `fk_articles_primary_category` FOREIGN KEY (`primary_category_id`) REFERENCES `categories` (`id`);

--
-- Tablo kısıtlamaları `article_tags`
--
ALTER TABLE `article_tags`
  ADD CONSTRAINT `fk_article_tags_article` FOREIGN KEY (`article_id`) REFERENCES `articles` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_article_tags_tag` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`id`) ON DELETE CASCADE;

--
-- Tablo kısıtlamaları `comments`
--
ALTER TABLE `comments`
  ADD CONSTRAINT `fk_comments_article` FOREIGN KEY (`article_id`) REFERENCES `articles` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

SET FOREIGN_KEY_CHECKS=1;