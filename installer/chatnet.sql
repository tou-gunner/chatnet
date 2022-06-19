SET FOREIGN_KEY_CHECKS=0;
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `chatnet`
--

-- --------------------------------------------------------

--
-- Table structure for table `cn_chat_groups`
--

DROP TABLE IF EXISTS `cn_chat_groups`;
CREATE TABLE IF NOT EXISTS `cn_chat_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `chat_room` int(11) NOT NULL,
  `cover_image` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_protected` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'True = 1, False = 0',
  `password` varchar(300) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `slug` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` smallint(6) NOT NULL DEFAULT '1' COMMENT 'ACTIVE = 1, INACTIVE = 2',
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cn_chat_groups_idx_id` (`id`),
  KEY `cn_chat_groups_idx_chat_room_slug` (`chat_room`,`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cn_chat_rooms`
--

DROP TABLE IF EXISTS `cn_chat_rooms`;
CREATE TABLE IF NOT EXISTS `cn_chat_rooms` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cover_image` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `room_notice_message` text COLLATE utf8mb4_unicode_ci,
  `room_notice_class` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_protected` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'True = 1, False = 0',
  `password` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_visible` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'True = 1, False = 0',
  `chat_validity` int DEFAULT NULL COMMENT 'hours',
  `slug` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `allowed_users` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `allow_guest_view` tinyint(1) DEFAULT NULL,
  `ad_chat_right_bar` text COLLATE utf8mb4_unicode_ci,
  `ad_chat_left_bar` text COLLATE utf8mb4_unicode_ci,
  `show_background` tinyint(1) DEFAULT NULL,
  `background_image` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` smallint NOT NULL DEFAULT '1' COMMENT 'ACTIVE = 1, INACTIVE = 2',
  `created_by` int DEFAULT NULL,
  `hide_chat_list` tinyint DEFAULT NULL,
  `disable_private_chats` tinyint DEFAULT NULL,
  `disable_group_chats` tinyint DEFAULT NULL,
  `user_list_type` tinyint DEFAULT NULL,
  `user_list_auth_roles` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT '[]',
  PRIMARY KEY (`id`),
  KEY `cn_chat_rooms_idx_created_by` (`created_by`),
  KEY `cn_chat_rooms_idx_status_is_visible` (`status`,`is_visible`),
  KEY `cn_chat_rooms_idx_slug` (`slug`),
  KEY `cn_chat_rooms_idx_id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cn_group_chats`
--

DROP TABLE IF EXISTS `cn_group_chats`;
CREATE TABLE IF NOT EXISTS `cn_group_chats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sender_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  `room_id` int(11) NOT NULL,
  `type` smallint(6) NOT NULL DEFAULT '1' COMMENT 'text= 1, image= 2, gif= 3',
  `message` text COLLATE utf8mb4_unicode_ci,
  `status` smallint(6) NOT NULL DEFAULT '1' COMMENT 'send= 1, seen = 2, deleted = 3',
  `time` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cn_group_chats_idx_id_group_id_sender_id` (`id`,`group_id`,`sender_id`),
  KEY `cn_group_chats_idx_group_id_room_id` (`group_id`,`room_id`),
  KEY `cn_group_chats_idx_id_group_id_room_id` (`id`,`group_id`,`room_id`),
  KEY `cn_group_chats_idx_updated_at_group_id` (`updated_at`,`group_id`),
  KEY `cn_group_chats_idx_sender_id` (`sender_id`),
  KEY `cn_group_chats_idx_sender_id_time_status` (`sender_id`, `status`, `time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cn_group_users`
--

DROP TABLE IF EXISTS `cn_group_users`;
CREATE TABLE IF NOT EXISTS `cn_group_users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user` int NOT NULL,
  `chat_group` int NOT NULL,
  `user_type` smallint NOT NULL DEFAULT '2' COMMENT 'Group admin = 1, Group user = 2, Guest user = 3',
  `status` smallint NOT NULL DEFAULT '1' COMMENT 'Active = 1, Inactive = 2',
  `is_typing` tinyint(1) NOT NULL DEFAULT '0',
  `is_muted` tinyint NOT NULL DEFAULT '0',
  `unread_count` int NOT NULL DEFAULT '0',
  `is_mod` tinyint(1) NOT NULL DEFAULT '0',
  `load_chats_from` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `cn_group_users_idx_chat_group` (`chat_group`),
  KEY `cn_group_users_idx_user` (`user`),
  KEY `cn_group_users_idx_user_chat_group` (`user`,`chat_group`),
  KEY `cn_group_users_idx_is_muted_user_chat_group` (`is_muted`,`USER`,`chat_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cn_ip_logs`
--

DROP TABLE IF EXISTS `cn_ip_logs`;
CREATE TABLE IF NOT EXISTS `cn_ip_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ip` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `country` varchar(3) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `time` datetime DEFAULT NULL,
  `type` int(11) NOT NULL DEFAULT '1' COMMENT '1 login, 2, register, 3 pass reset',
  `message` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cn_languages`
--

DROP TABLE IF EXISTS `cn_languages`;
CREATE TABLE IF NOT EXISTS `cn_languages` (
  `code` varchar(5) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country` varchar(5) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `direction` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ltr',
  `google_font_family` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cn_lang_terms`
--

DROP TABLE IF EXISTS `cn_lang_terms`;
CREATE TABLE IF NOT EXISTS `cn_lang_terms` (
  `id` int NOT NULL AUTO_INCREMENT,
  `term` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `section` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
-- --------------------------------------------------------

--
-- Table structure for table `cn_private_chats`
--

DROP TABLE IF EXISTS `cn_private_chats`;
CREATE TABLE IF NOT EXISTS `cn_private_chats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_1` int(11) NOT NULL,
  `user_2` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `room_id` int(11) NOT NULL,
  `type` smallint(6) NOT NULL DEFAULT '1' COMMENT 'text=1, image=2, gif=3',
  `message` text COLLATE utf8mb4_unicode_ci,
  `status` smallint(6) NOT NULL DEFAULT '1' COMMENT 'send= 1, seen = 2, deleted = 3',
  `time` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cn_private_chats_idx_id` (`id`),
  KEY `cn_private_chats_idx_user_1_user_2_room_id_sender_id` (`user_1`,`user_2`,`room_id`,`sender_id`),
  KEY `cn_private_chats_idx_user_1_user_2_room_id` (`user_1`,`user_2`,`room_id`),
  KEY `cn_private_chats_idx_id_user_1_user_2_room_id` (`id`,`user_1`,`user_2`,`room_id`),
  KEY `cn_private_chats_idx_updated_at_user_1_user_2_room_id` (`updated_at`,`user_1`,`user_2`,`room_id`),
  KEY `cn_private_chats_idx_user_2_sender_id` (`user_2`,`sender_id`),
  KEY `cn_private_chats_idx_user_1_sender_id` (`user_1`,`sender_id`),
  KEY `cn_private_chats_idx_sender_id_time_status` (`sender_id`, `status`, `time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cn_private_chat_meta`
--

DROP TABLE IF EXISTS `cn_private_chat_meta`;
CREATE TABLE IF NOT EXISTS `cn_private_chat_meta` (
  `id` int NOT NULL AUTO_INCREMENT,
  `from_user` int NOT NULL,
  `to_user` int NOT NULL,
  `room_id` int DEFAULT NULL,
  `is_typing` tinyint(1) DEFAULT '0',
  `is_blocked` tinyint(1) DEFAULT '0',
  `is_favourite` tinyint(1) DEFAULT '0',
  `is_muted` tinyint DEFAULT '0',
  `unread_count` int DEFAULT '0',
  `last_chat_id` int DEFAULT NULL,
  `load_chats_from` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cn_private_chat_me_idx_to_user_room_id_from_user` (`to_user`,`room_id`,`from_user`),
  KEY `cn_private_chat_me_idx_from_user_to_user` (`from_user`,`to_user`),
  KEY `cn_private_chat_me_idx_is_muted_from_user_to_user` (`is_muted`,`from_user`,`to_user`),
  KEY `cn_private_chat_me_idx_from_user_to_user_id` (`from_user`,`to_user`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cn_push_devices`
--

DROP TABLE IF EXISTS `cn_push_devices`;
CREATE TABLE IF NOT EXISTS `cn_push_devices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `token` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `device` varchar(300) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `perm_group` tinyint(1) NOT NULL DEFAULT '0',
  `perm_private` tinyint(1) NOT NULL DEFAULT '1',
  `perm_mentions` tinyint(1) NOT NULL DEFAULT '1',
  `perm_notice` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cn_radio_stations`
--

DROP TABLE IF EXISTS `cn_radio_stations`;
CREATE TABLE IF NOT EXISTS `cn_radio_stations` (
  `id` smallint(6) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `source` text COLLATE utf8mb4_unicode_ci,
  `image` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cn_settings`
--

DROP TABLE IF EXISTS `cn_settings`;
CREATE TABLE IF NOT EXISTS `cn_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `value` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cn_social_logins`
--

DROP TABLE IF EXISTS `cn_social_logins`;
CREATE TABLE IF NOT EXISTS `cn_social_logins` (
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_key` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `secret_key` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cn_translations`
--

DROP TABLE IF EXISTS `cn_translations`;
CREATE TABLE IF NOT EXISTS `cn_translations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lang_code` varchar(5) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `term_id` int(11) DEFAULT NULL,
  `translation` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `cn_translations_idx_term_id_lang_code` (`term_id`,`lang_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cn_users`
--

DROP TABLE IF EXISTS `cn_users`;
CREATE TABLE IF NOT EXISTS `cn_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `first_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `sex` smallint(6) DEFAULT NULL COMMENT 'MALE = 1, FEMALE = 2, OTHER = 3',
  `avatar` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password` varchar(300) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `about` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_status` smallint(6) DEFAULT '1' COMMENT 'ONLINE = 1, OFFLINE = 2, BUSY = 3',
  `available_status` smallint(6) DEFAULT '1' COMMENT 'ACTIVE = 1, INACTIVE = 2',
  `last_seen` datetime NULL DEFAULT NULL,
  `last_login` datetime NULL DEFAULT NULL,
  `user_type` smallint(6) NOT NULL DEFAULT '2' COMMENT 'Admin = 1, Chat User = 2',
  `reset_key` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `timezone` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT 'Asia/Colombo',
  `country` varchar(3) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `activation_key` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `auth_key` varchar(256) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_name` (`user_name`,`email`),
  KEY `cn_users_idx_id` (`id`),
  KEY `cn_users_idx_user_type` (`user_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for table `cn_users`
--
ALTER TABLE `cn_users` ADD FULLTEXT KEY `name` (`first_name`,`last_name`);

--
-- Dumping data for table `cn_settings`
--

INSERT INTO `cn_settings` (`id`, `name`, `value`) VALUES
(1, 'timezone', 'Asia/Colombo'),
(2, 'chat_receive_seconds', '3'),
(3, 'user_list_check_seconds', '5'),
(4, 'chat_status_check_seconds', '3'),
(5, 'online_status_check_seconds', '10'),
(6, 'typing_status_check_seconds', '3'),
(7, 'current_version', '1.8.2'),
(8, 'enable_gif', '1'),
(9, 'enable_stickers', '1'),
(10, 'enable_images', '1'),
(11, 'member_registration', '1'),
(12, 'homepage_chat_room_view', 'small'),
(13, 'site_name', 'ChatNet'),
(14, 'sent_animation', 'animate__fadeIn'),
(15, 'replies_animation', 'animate__fadeIn'),
(16, 'radio', '0'),
(17, 'enable_social_login', '0'),
(18, 'push_notifications', '0'),
(19, 'pwa_enabled', '0'),
(20, 'allow_multiple_sessions', '1'),
(21, 'push_provider', 'firebase'),
(22, 'guest_inactive_hours', '48'),
(23, 'enable_recaptcha', '0'),
(24, 'enable_ip_logging', '0'),
(25, 'enable_ip_blacklist', '0'),
(26, 'autodetect_country', '0'),
(27, 'geoip_api_endpoint', 'https://freegeoip.app/json/'),
(29, 'enable_email_verification', '0'),
(30, 'disable_join_confirmation', '0'),
(31, 'email_smtp', '0'),
(32, 'enable_multiple_languages', '0'),
(33, 'delete_group_chat_hours', '0'),
(34, 'delete_private_chat_hours', '0'),
(35, 'only_online_users', '0'),
(36, 'hide_chat_list', '0'),
(37, 'disable_private_chats', '0'),
(38, 'domain_filter', '0'),
(39, 'domains_list', ''),
(40, 'sso_enabled', '0'),
(41, 'sso_home_url', ''),
(42, 'sso_allowed_orgins', ''),
(43, 'sso_login_url', ''),
(44, 'sso_logout_url', ''),
(45, 'sso_allow_profile_edit', '0'),
(46, 'flood_control_message_limit', '1'),
(47, 'flood_control_time_limit', '1'),
(48, 'enable_codes', '1'),
(49, 'user_list_auth_roles', '[]'),
(50, 'boxed_bg', '0'),
(51, 'disable_group_chats', '0'),
(52, 'user_list_type', '1'),
(53, 'chatpage_layout', 'full'),
(54, 'cloud_storage', '0'),
(55, 'cloud_storage_type', 'aws'),
(56, 'cloud_storage_endpoint', ''),
(57, 'cloud_storage_region', ''),
(58, 'cloud_storage_key', ''),
(59, 'cloud_storage_secret', ''),
(60, 'cloud_storage_bucket', ''),
(61, 'cloud_storage_url', ''),
(62, 'cloud_storage_ssl_verify', '');


INSERT INTO `cn_languages` (`code`, `name`, `country`) VALUES
('en', 'English', 'us');

DROP TABLE IF EXISTS `cn_reports`;
CREATE TABLE IF NOT EXISTS `cn_reports` (
  `id` int NOT NULL AUTO_INCREMENT,
  `report_type` smallint NOT NULL DEFAULT '1' COMMENT 'chat=1, user=2, room=3, group=4',
  `report_for` int NOT NULL,
  `chat_type` int DEFAULT NULL COMMENT 'private=1, group=2',
  `report_reason` int DEFAULT NULL,
  `report_comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `reported_by` int DEFAULT NULL,
  `reported_at` datetime DEFAULT NULL,
  `status` smallint NOT NULL COMMENT 'reported=1, read=2',
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DROP TABLE IF EXISTS `cn_report_reasons`;
CREATE TABLE IF NOT EXISTS `cn_report_reasons` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_general_ci,
  `reason_for` smallint NOT NULL DEFAULT '0' COMMENT 'all=0, chat=1, user=2, room=3, group=4',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `cn_report_reasons` (`id`, `title`, `description`, `reason_for`) VALUES
(1, 'report_reason_1', 'report_reason_1_description', 0),
(2, 'report_reason_2', 'report_reason_2_description', 0),
(3, 'report_reason_3', 'report_reason_3_description', 0),
(4, 'report_reason_4', 'report_reason_4_description', 0),
(5, 'report_reason_5', 'report_reason_5_description', 0),
(6, 'report_reason_6', 'report_reason_6_description', 0),
(7, 'report_reason_7', 'report_reason_7_description', 0),
(8, 'report_reason_8', 'report_reason_8_description', 0),
(9, 'report_reason_9', 'report_reason_9_description', 0),
(10, 'report_reason_10', 'report_reason_10_description', 0);

DROP TABLE IF EXISTS `cn_chat_interactions`;
CREATE TABLE IF NOT EXISTS `cn_chat_interactions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `chat_id` int NOT NULL,
  `user_id` int NOT NULL,
  `chat_type` smallint NOT NULL DEFAULT '1' COMMENT 'Private Chat = 1, Group Chat = 2 ',
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `is_notified` tinyint(1) NOT NULL DEFAULT '0',
  `is_starred` tinyint(1) NOT NULL DEFAULT '0',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `read_at` datetime DEFAULT NULL,
  `notified_at` datetime DEFAULT NULL,
  `starred_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cn_chat_interactio_idx_is_noti_chat_ty_user_id_chat_id` (`is_notified`,`chat_type`,`user_id`,`chat_id`),
  KEY `cn_chat_interactio_idx_chat_ty_user_id_chat_id` (`chat_type`, `user_id`, `chat_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Table structure for table `cn_notifications`
--

CREATE TABLE IF NOT EXISTS `cn_notifications`(
    `id` INT NOT NULL AUTO_INCREMENT,
    `type` TINYINT NULL DEFAULT '1' COMMENT '1=general, 2=mention, 3=reminder',
    `content` VARCHAR(300) NULL DEFAULT NULL,
    `user_id` INT NULL DEFAULT NULL,
    `created_at` datetime DEFAULT NULL,
    `is_read` BOOLEAN NULL DEFAULT FALSE,
    `read_at` DATETIME NULL DEFAULT NULL,
    PRIMARY KEY(`id`),
    KEY `cn_notifications_idx_user_id_is_read` (`user_id`,`is_read`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- SENG ADD

CREATE TABLE IF NOT EXISTS `cn_user_extend`(
    `id` INT NOT NULL,
    `about` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
    `user_status` smallint(6) DEFAULT '1' COMMENT 'ONLINE = 1, OFFLINE = 2, BUSY = 3',
    `available_status` smallint(6) DEFAULT '1' COMMENT 'ACTIVE = 1, INACTIVE = 2',
    `last_seen` datetime NULL DEFAULT NULL,
    `last_login` datetime NULL DEFAULT NULL,
    `user_type` smallint(6) NOT NULL DEFAULT '2' COMMENT 'Admin = 1, Chat User = 2',
    `timezone` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT 'Asia/Colombo',
    `country` varchar(3) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
    PRIMARY KEY(`id`),
    KEY `cn_users_idx_id` (`id`),
    KEY `cn_users_idx_user_type` (`user_type`)
)

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
