/*
 Navicat MySQL Dump SQL

 Source Server         : world
 Source Server Type    : MySQL
 Source Server Version : 100432 (10.4.32-MariaDB)
 Source Host           : localhost:3306
 Source Schema         : worldwar

 Target Server Type    : MySQL
 Target Server Version : 100432 (10.4.32-MariaDB)
 File Encoding         : 65001

 Date: 29/06/2025 18:35:12
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for player_vehicles
-- ----------------------------
DROP TABLE IF EXISTS `player_vehicles`;
CREATE TABLE `player_vehicles`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `player_id` int NOT NULL,
  `vehicle_model` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `plate` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `is_stored` tinyint(1) NULL DEFAULT 1,
  `garage` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `plate`(`plate` ASC) USING BTREE,
  INDEX `player_id`(`player_id` ASC) USING BTREE,
  CONSTRAINT `player_vehicles_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of player_vehicles
-- ----------------------------

-- ----------------------------
-- Table structure for player_weapons
-- ----------------------------
DROP TABLE IF EXISTS `player_weapons`;
CREATE TABLE `player_weapons`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `player_id` int NOT NULL,
  `weapon_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `ammo` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `player_id`(`player_id` ASC) USING BTREE,
  CONSTRAINT `player_weapons_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of player_weapons
-- ----------------------------

-- ----------------------------
-- Table structure for players
-- ----------------------------
DROP TABLE IF EXISTS `players`;
CREATE TABLE `players`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `identifier` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `faction` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `kills` int NULL DEFAULT 0,
  `deaths` int NULL DEFAULT 0,
  `is_premium` tinyint(1) NULL DEFAULT 0,
  `is_admin` tinyint(1) NULL DEFAULT 0,
  `money` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `identifier`(`identifier` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of players
-- ----------------------------
INSERT INTO `players` VALUES (3, 'license:b1ecf5348bd4d5b3abd09e0272a97059d93e9c8d', 'Failure', 'nac', 0, 0, 0, 0, 0);

SET FOREIGN_KEY_CHECKS = 1;
