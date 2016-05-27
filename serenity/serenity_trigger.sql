#######
#
# @Desc: Trigger d'inscription, changement de mdp
#        bases de données lovewow.forum_users, auth.account
#
# @Autheur: Neonix
#
######

#AJout de la colum
#ALTER TABLE `serenity`.`users` 
#ADD COLUMN `passwordS` VARCHAR(40) NULL AFTER `activate_key`;


#Trigger d'inscription (site)
USE `serenity`;
DROP TRIGGER IF EXISTS `serenity`.`Users_AFTER_INSERT`;
DELIMITER $$
CREATE DEFINER = CURRENT_USER TRIGGER `serenity`.`Users_AFTER_INSERT` AFTER INSERT ON `users` FOR EACH ROW
BEGIN

	#WOW BC
	INSERT INTO BCauth.account
	(id, username, sha_pass_hash, email, expansion)
	VALUE
	(new.id, new.username, SHA1(CONCAT(UPPER(new.username), ':', UPPER(new.passwordS))), new.email, 1);
    
	#WOW CATA
	INSERT INTO CATAauth.account
	(id, username, sha_pass_hash, email, expansion)
	VALUE
	(new.id, new.username, SHA1(CONCAT(UPPER(new.username), ':', UPPER(new.passwordS))), new.email, 1);    

END;$$
DELIMITER ;




#Trigger de changement de mdp (forum)
use `serenity`;
Drop trigger IF EXISTS Users_AINS;
DELIMITER $$

CREATE DEFINER=`root`@`localhost` TRIGGER `Users_AINS` AFTER update ON `users` FOR EACH ROW
BEGIN

SET @INC = 0;

IF( new.passwordS <> old.passwordS)
THEN
	#WOW BC
	UPDATE BCauth.account
	SET sha_pass_hash = SHA1(CONCAT(UPPER(new.username), ':', UPPER(new.passwordS))),
	sessionkey="", v="", s=""
	WHERE username=new.username;
    
	#WOW CATA
	UPDATE CATAauth.account
	SET sha_pass_hash = SHA1(CONCAT(UPPER(new.username), ':', UPPER(new.passwordS))),
	sessionkey="", v="", s=""
	WHERE username=new.username;
    
END IF;


END;$$
DELIMITER ;
