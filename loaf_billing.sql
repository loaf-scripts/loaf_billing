-- DROP TABLE `loaf_invoices`;

CREATE TABLE IF NOT EXISTS `loaf_invoices` (
    `id` VARCHAR(15), -- unique bill id
    `issued` DATE DEFAULT (CURRENT_DATE), -- the date the bill was issued

    `biller` VARCHAR(150) NOT NULL, -- the identifier who issued the bill
    `biller_name` VARCHAR(150) NOT NULL, -- the name of the person who issued the bill
    `billed` VARCHAR(150) NOT NULL, -- the identifier who received the bill
    `billed_name` VARCHAR(150) NOT NULL, -- the name of the person who received the bill
    `owner` VARCHAR(150) NOT NULL, -- current person that has the bill

    `due` DATE NOT NULL, -- last date for signing, before interest starts
    `interest` INT NOT NULL DEFAULT 0, -- interest, in percent 
    `late` INT NOT NULL DEFAULT 0, -- how many days late the invoice was paid

    `amount` INT NOT NULL DEFAULT 0, -- the price of the bill
    `name` VARCHAR(150) NOT NULL, -- the name of the bill, used by scripts
    `description` VARCHAR(150) NOT NULL DEFAULT "Unknown", -- the bill description (shown to players)

    `company` VARCHAR(50),
    `company_name` VARCHAR(150),

    `signed` BOOLEAN NOT NULL DEFAULT 0, -- if the bill has been paid
    `signature` LONGTEXT, -- image data (url/base64) for the signature

    PRIMARY KEY (`id`)
);
