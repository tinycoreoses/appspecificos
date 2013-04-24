appspecificos
=============

This project aims in creating an application specific OS

The base minimal OS used in this project is Tinycorelinux

The repo has 3 folders :

	src	
		src folder has in turn 3 folders:		
			elinks			
				1. Place backup.sh with 777 rights in /usr/bin				
				2. Place onboot.lst in /mnt/sda/tce/
				3. Place tc-functions, tc-config in /etc/init.d/
				4. Place rest of the files in /home/tc/
			abiword	
				1. Place backup.sh with 777 rights in /usr/bin
				2. Place onboot.lst in /mnt/sda/tce/
				3. Place tc-functions, tc-config in /etc/init.d/
				4. Place rest of the files in /home/tc/
			firefox	
				1. Place backup.sh with 777 rights in /usr/bin
				2. Place onboot.lst in /mnt/sda/tce/
				3. Place tc-functions, tc-config in /etc/init.d/
				4. Place rest of the files in /home/tc/
	test
		This folder has test transactions
