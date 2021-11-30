# Wireguard user creation script

Simple script that facilitates the creation of new users for a wireguard vpn server.

### Before first run :

You will need to set you public ip or your dyndns domain name in the script on line 62:

```
echo "Endpoint = <your public ip or you domain name here>:47111" >> "${name}.conf"
```

### Note :

Script was made to work on a raspberry pi running wireguard. At the end of the script, the user config file is copied to /home/pi.
Make sure to change the home dir path of the user you want the config file to be copied to.
