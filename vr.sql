CREATE TABLE `vrinventories` (
	`identifier` LONGTEXT NOT NULL COLLATE 'utf8mb4_general_ci',
	PRIMARY KEY (`identifier`(10)) USING BTREE
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB;


CREATE TABLE `vrscore` (
	`team` LONGTEXT NOT NULL COLLATE 'utf8mb4_general_ci',
	`teamName` LONGTEXT NOT NULL COLLATE 'utf8mb4_general_ci',
	`time` LONGTEXT NOT NULL COLLATE 'utf8mb4_general_ci'
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB;


INSERT INTO `items` (`item_name`, `item_label`, `photo`, `weight`, `can_give`, `can_store`, `can_drop`, `is_stackable`, `usable`) VALUES ('vrCoins', 'VR Coins', 'https://i.imgur.com/ue80JX0.png', 0, 1, 1, 1, 1, 1);
INSERT INTO `items` (`item_name`, `item_label`, `photo`, `weight`, `can_give`, `can_store`, `can_drop`, `is_stackable`, `usable`) VALUES ('cajaCartuchos', 'Caja de 20 Cartuchos', 'https://i.imgur.com/8WgBqqx.png', 1, 1, 1, 1, 1, 1);
INSERT INTO `items` (`item_name`, `item_label`, `photo`, `weight`, `can_give`, `can_store`, `can_drop`, `is_stackable`, `usable`) VALUES ('ifak', 'IFAK', 'https://i.imgur.com/EhFqeau.png', 1, 1, 1, 1, 1, 1);
INSERT INTO `items` (`item_name`, `item_label`, `photo`, `weight`, `can_give`, `can_store`, `can_drop`, `is_stackable`, `usable`) VALUES ('cprKit', 'Kit de Reanimacion', 'https://i.imgur.com/ElGx2bK.jpg', 1, 1, 1, 1, 1, 1);
