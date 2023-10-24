#!/bin/bash
# Obter o endereço IP atual do servidor
SERVER_IP=$(curl -s http://checkip.amazonaws.com)
# Substituir o conteúdo do arquivo "/www/server/panel/data/iplist.txt" pelo IP do servidor
echo "$SERVER_IP" > /www/server/panel/data/iplist.txt
# Read customer ID
echo "Enter customer ID: "
read customer_id
read -p "Did the customer buy the backup service? (y/n): " backup_choice



# Update hostname with customer ID
hostnamectl set-hostname "$customer_id"

# Generate new SSH host key
ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N "" -t rsa 

# Remove any existing known_hosts keys for the host
sed -i "/^[^#]*$(hostname)/d" ~/.ssh/known_hosts

# Restart the SSH service to use the new host key
systemctl restart ssh

#Tor
# Delete files in /var/lib/tor/torimpreza
rm -rf /var/lib/tor/torimpreza/*

# Restart Tor service
systemctl restart tor
systemctl enable tor
sed -i "s/aaPanel linux panel/Tor Impreza - $customer_id/g" /www/server/panel/config/config.json


if [ "$backup_choice" == "y" ]; then
  echo "@reboot /opt/ImprezaBackup/backup-daemon-start-background.sh" | sudo crontab -
  wget -O install.run --content-disposition --post-data 'SelfAddress=https%3A%2F%2Fbackup.imprezahost.com%2F&Platform=7' 'https://backup.imprezahost.com/api/v1/admin/branding/generate-client/by-platform'
  chmod +x install.run
  export COMET_USERNAME=tor
  export COMET_PASSWORD=R4BaQqdCKn
  (echo $COMET_USERNAME; echo $COMET_PASSWORD;) | ./install.run
else
  echo "Backup download skipped."
fi

# Function to generate a random string of length 6 with letters and numbers
generate_random_string() {
  echo $(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
}

# Generate random username and password
username=$(generate_random_string)
password=$(generate_random_string)

echo "Generated username: $username"
echo "Generated password: $password"

(sleep 3; echo "$username";) | bt 6
(sleep 3; echo "$password";) | bt 5
# Display aapanel login information
bt 14
echo "$password"
# Display contents of /var/lib/tor/torimpreza/hostname
cat /var/lib/tor/torimpreza/hostname

