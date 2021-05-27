#Diese Shell die Parameter Username, Password, System von aussen
sudo service apache2 restart

sleep 30s

CLASSPATH=/home/pi/Fungarium/lib/com-dhbw-fungarium.jar:/home/pi/Fungarium/lib/log4j-api-2.14.0.jar:/home/pi/Fungarium/lib/log4j-core-2.14.0.jar:/home/pi/Fungarium/lib/mysql-connector-java-8.0.22.jar:/home/pi/Fungarium/lib/pi4j-core.jar

# Set userDB, passwordDB and nameDB
userDB=
USERDB=-DuserDB=$userDB
passwordDB=
PASSWORDDB=-DpasswordDB=$passwordDB
nameDB=
NAMEDB=-DnameDB=$nameDB

# Overwrite default logging config
LOGGING_CONFIG=-Dlog4j.configurationFile=/home/pi/Fungarium/config/fungarium_logging.xml

#Rules Properties_File
PROPERTIES_FILE=-Dfungarium.rules=/home/pi/Fungarium/config/rules.properties

#echo "Logging to directory: " $FUNGARIUM_LOG_DIR

# Start fungarium
java $USERDB $PASSWORDDB $NAMEDB $LOGGING_CONFIG $PROPERTIES_FILE -classpath $CLASSPATH com.dhbw.fungarium.FungariumMain 
#java $FUNGARIUM_LOGGING $LOGGING_CONFIG -classpath $CLASSPATH com.dhbw.fungarium.FungariumMain 
