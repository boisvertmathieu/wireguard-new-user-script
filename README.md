# Wireguard user creation script

Simple script that facilitates the creation of new users for a wireguard vpn server.

### Before running the script :

You will need to set you public ip or your dyndns domain name in the script here:

```
echo "Endpoint = <your public ip or you domain name here>:47111" >> "${name}.conf"
```

Of course, you will also need to have port forwarded the port 47111 in your router to your wireguard server as well.

Also, set the proper user name and home dir path at the end of the script here :
```
cp /etc/wireguard/${name}.conf <user home dir path here (ex. /home/pir)>
chown -R pi <user home dir path here>/${name}.conf
```

### Note :

The script was made to work on a raspberry pi running wireguard. At the end of the script, the user config file is copied to /home/pi.
Make sure to change the home dir path of the user you want the config file to be copied to.
