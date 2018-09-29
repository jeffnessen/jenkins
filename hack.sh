# Trust DTR Cert
openssl s_client -connect $DTR_SERVER:443 -showcerts </dev/null 2>/dev/null \
    | openssl x509 -outform PEM \
    | sudo tee /usr/local/share/ca-certificates/$DTR_SERVER.crt
sudo update-ca-certificates --fresh

# Download Client bundle if it doesn't already exist on the drive
if [ ! -f /var/jenkins_home/bundle.zip ]; then 
   AUTHTOKEN=$(curl -sk -d '{"username":"$JENKINS_USERNAME","password":"$JENKINS_PASSWORD"}' https://$UCP_SERVER/auth/login | jq -r .auth_token)
   curl -k -H "Authorization: Bearer $AUTHTOKEN" https://$UCP_SERVER/api/clientbundle -o /var/jenkins_home/bundle.zip
   unzip /var/jenkins_home/bundle.zip -d /var/jenkins_home/.docker

   sudo sed -i "\$aexport DOCKER_TLS_VERIFY=1\nexport DOCKER_HOST=tcp://$UCP_SERVER:443" /etc/profile
fi
#EOT
