#!/bin/bash

#Installation for fungarium/terrarium project T3100
#created by Robin Lägler (robin.laegler@googlemail.com)

echo "Installation for fungarium/terrarium project T3100"

before_reboot(){

    #starting installation
    echo "start fungarium installation"

    #entering domainaddress
    echo "enter your created domainaddress (Example: example.ddnss.de)"
    read -p 'Domainaddress: ' domainaddress
    echo $domainaddress

    #updating packages on raspbian
    echo -e "\e[1;33;41m updating packages \e[0m"
    sudo apt-get update
    
    #installing Python3
    echo -e "\e[1;33;41m installing Python3 \e[0m"
    sudo apt-get install python3
    
    #installing OpenJDK Java 8
    echo -e "\e[1;33;41m installing OpenJDK Java 8 \e[0m"
    sudo apt install openjdk-8-jdk
    
    #updating GPIO Pins
    echo -e "\e[1;33;41m updating GPIO Pins \e[0m"
    wget /tmp https://project-downloads.drogon.net/wiringpi-latest.deb
    sudo dpkg -i wiringpi-latest.deb
    
    #installing the CircuitPython-DHT Library
    echo -e "\e[1;33;41m installing the CircuitPython-DHT Library \e[0m"
    pip3 install adafruit-circuitpython-dht
    sudo apt-get install libgpiod2
    
    #downloading Java-Data from Github
    #echo -e "\e[1;11;41m downloading Java-Data from Github \e[0m"
    #sudo git clone https://github.com/svenSchelling/Fungarium.git /home/pi/Fungarium

    #downloading and installing apache2
    echo -e "\e[1;33;41m downloading and installing apache2 \e[0m"
    sudo apt-get install apache2 -y

    #creating virtual host
    echo -e "\e[1;33;41m creating virtual host \e[0m"

    #installing git to get php and java data
    echo -e "\e[1;11;41m installing git \e[0m"
    sudo apt install git

    #downloading php data for the apache server from Github
    sudo git clone https://github.com/robinlaegler/FungariumPHPSteuerungsseite.git /var/www/$domainaddress/public_html

    #sudo git clone https://github.com/robinlaegler/Fungarium.git
    sudo touch /etc/apache2/sites-available/$domainaddress.conf
    sudo chown pi /etc/apache2/sites-available/$domainaddress.conf

    #entering mail-address for initialising virtual host
    read -p 'e-mail-address Server Admin: ' mail
    
    #add domain to /etc/hosts
    echo "0.0.0.0       $domainaddress" | sudo tee -a /etc/hosts
    
    #creating virtual host file
    echo  "<VirtualHost $domainaddress:80>

	ServerAdmin $mail

	ServerName $domainaddress

	ServerAlias www.$domainaddress

	DocumentRoot /var/www/$domainaddress/public_html

	ErrorLog ${APACHE_LOG_DIR}/error.log

	CustomLog ${APACHE_LOG_DIR}/access.log combined

    </VirtualHost>" > /etc/apache2/sites-available/$domainaddress.conf

    #enabling virtual host
    echo -e "\e[1;11;41m enabling virtual host \e[0m"
    sudo a2ensite $domainaddress.conf
    echo -e "\e[1;11;41m successfully created virtual host  \e[0m"

    #restarting apache server to ensure change
    echo -e "\e[1;33;41m restarting apache server \e[0m"
    sudo systemctl restart apache2

    #creating .htaccess file to make sure only verified user can enter the website
    echo -e "\e[1;33;41m creating .htaccess file \e[0m"
    sudo chown pi /etc/apache2/apache2.conf
    
    domainaddress="$domainaddress"

    sudo sed -i "s|<Directory /var/www/>|<Directory /var/www/${domainaddress}/>|" /etc/apache2/apache2.conf
    sudo sed -i s/"AllowOverride None"/"AllowOverride AuthConfig"/g /etc/apache2/apache2.conf
    
    #restarting apache server to ensure change
    echo -e "\e[1;33;41m restarting apache server \e[0m"
    sudo systemctl restart apache2
    sudo chmod -R 777 /var/www/$domainaddress
    sudo echo "AuthType Basic

     AuthName 'Sicherer Bereich!'

     AuthUserFile /var/www/$domainaddress/.htpasswd

     Require valid-user" > /var/www/$domainaddress/.htaccess

    #create user to have access to the website
    echo -e "\e[1;33;41m create username and password for apache-user \e[0m"
    read -p 'username: ' username
    sudo htpasswd -c /var/www/$domainaddress/.htpasswd $username

    #installing ACME to get an SSL-certificate 
    echo -e "\e[1;33;41m install ACME Certbot to get a SSL-certificate and enable HTTPS-connection\e[0m"

    #installing snapd to install ACME Certbot
    echo -e "\e[1;11;41m installing snapd \e[0m"
    sudo apt install snapd

    #rebooting system to ensure change
    echo -e "\e[1;33;41m please reboot the raspberry pi to guarantee the successful installation of snapd \e[0m"

    #creating help file to seperate before and after reebot
    echo -e "\e[1;33;41m creating help file to seperate before and after reebot \e[0m"
    sudo touch /home/pi/myscripts/rebootingUpdates
    sudo chmod -R 777 /home/pi/myscripts/rebootingUpdates
    sudo echo "$domainaddress" > /home/pi/myscripts/rebootingUpdates
    
    while true 
    do
	read -p "Do you want to reboot? (y / n)" response

	if [ "$response" == "y" ]; then

	    echo "rebooting..."
	    break

	fi
    done

}

after_reboot(){

    sudo chmod -R 777 /home/pi/myscripts/rebootingUpdates
    domainaddress="`cat /home/pi/myscripts/rebootingUpdates`"
    echo "$domainaddress"
    
    #checking snapd version
    echo -e "\e[1;31;41m checking snapd version \e[0m"
    sudo snap install core
    sudo snap refresh 
    
    #installing certbot
    echo -e "\e[1;31;41m installing certbot \e[0m"    
    sudo snap install --classic certbot
    sudo ln -s /snap/bin/certbot /usr/bin/certbot
    sudo certbot
    
    #installing PHP
    echo -e "\e[1;31;41m installing PHP \e[0m"  
    sudo apt-get install php -y
    
    #installing MySQL-Database
    echo -e "\e[1;31;41m installing MySQL-Database \e[0m"      
    sudo apt-get install mariadb-server php-mysql -y
    
    #restarting apache server to ensure change
    echo -e "\e[1;33;41m restarting apache server \e[0m"
    sudo systemctl restart apache2 

    #installing PHPMyAdmin to visualize the DB-data
    echo -e "\e[1;31;41m installing PHPMyAdmin \e[0m"  
    echo -e "\e[1;11;41m please select apache2 as the webserver your using \e[0m"  
    sudo apt install phpmyadmin
    
    #creating a user to enter the database 
    echo -e "\e[1;11;41m creating a user to enter the database \e[0m"  
    read -p 'Username database: ' usernameDB
    while true; do
	read -s -p "Password database: " passwordDB
	echo
	read -s -p "Password database (again): " password2
	echo
	[ "$passwordDB" = "$password2" ] && break
	echo "Please try again"
    done
    sudo mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'pass';"
    sudo mysql -u root -p'pass' -e "GRANT ALL PRIVILEGES ON *.* TO '${usernameDB}'@'localhost' IDENTIFIED BY '${passwordDB}' WITH GRANT OPTION;"

    #restarting apache server to ensure change
    echo -e "\e[1;33;41m restarting apache server \e[0m"
    sudo systemctl restart apache2    
     
    #creating database 
    echo -e "\e[1;33;41m creating database \e[0m"
    
    echo -e "\e[1;33;41m which system do you want to provide \e[0m"
    while true 
    do
	read -p "Terrarium / Fungarium ? (t / f)" response

	if [ "$response" == "t" ]; then

	    echo "Terrarium"
	    system=terrarium
	    break

	fi
	if [ "$response" == "f" ]; then

	    echo "Fungarium"
	    system=fungarium
	    break

	fi
	
    done
    
    #creating fungarium/terrarium database
    sudo mysql -u root -p'pass' -e "CREATE DATABASE IF NOT EXISTS ${system};"
    
    #overwriting DatabaseLogin.php to enter username password and database
    echo -e "\e[1;33;41m overwriting databaseLogin.php to enter username password and database \e[0m"
    sudo sed -i "s|'username'|'$usernameDB'|" /var/www/$domainaddress/public_html/databaseLogin.php
    sudo sed -i "s|'password'|'$passwordDB'|" /var/www/$domainaddress/public_html/databaseLogin.php
    sudo sed -i "s|'system'|'$system'|" /var/www/$domainaddress/public_html/databaseLogin.php
    
    sudo sed -i '$a# Database Username' /home/pi/Fungarium/config/rules.properties
    sudo sed -i '$ausernameDB='$usernameDB'' /home/pi/Fungarium/config/rules.properties
    sudo sed -i '$a# Database Password' /home/pi/Fungarium/config/rules.properties
    sudo sed -i '$apasswordDB='$passwordDB'' /home/pi/Fungarium/config/rules.properties
    sudo sed -i '$a# Database System' /home/pi/Fungarium/config/rules.properties
    sudo sed -i '$asystemDB='$system'' /home/pi/Fungarium/config/rules.properties

    #deleting help file to seperate before and after reebot
    echo -e "\e[1;33;41m deleting help file to seperate before and after reebot \e[0m"
    sudo rm /home/pi/myscripts/rebootingUpdates
    
    #creating autostart of java application
    sudo nano /etc/xdg/autostart/fungarium.desktop
    sudo chmod -R 777 /etc/xdg/autostart/fungarium.desktop
    if ! grep -q "[Desktop Entry]
	Name=fungarium
	Exec=sh /home/pi/Fungarium/start_fungarium.sh
	Terminal=false" /etc/xdg/autostart/fungarium.desktop
    then
	sudo echo  "[Desktop Entry]
	Name=fungarium
	Exec=sh /home/pi/Fungarium/start_fungarium.sh
	Terminal=false" > /etc/xdg/autostart/fungarium.desktop
    fi
}



if [ -f /home/pi/myscripts/rebootingUpdates ]; then

    after_reboot

else

    before_reboot

    sudo reboot

fi



