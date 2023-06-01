#!/bin/bash
C=RU
ST=Tomsk
L=Tomskaya
O=Worldskills
OU=IT
EMAIL=support@demo.lab
pass=xxXX1234

curl -s https://raw.githubusercontent.com/ragevna/F7/main/openssl.cnf >> /ca/openssl.cnf
sed -i "s/IP\.1 = <INSERT IWTM IP>/IP.1 = $(ifconfig ens192 | awk '/inet /{print $2}')/g" /ca/openssl.cnf


openssl req -x509 -newkey rsa:4096 -keyout ca.key -out ca.crt -subj "/C=$C/ST=$ST/L=$L/O=$O/OU=$OU/CN=Demo.lab RootCA/emailAddress=$EMAIL" -days 3650 -extensions v3_ca  -passout pass:"$pass" 2>/dev/null
openssl req -newkey rsa:4096 -passout pass:"$pass" -config openssl.cnf -keyout server.key -out server.csr -subj "/C=$C/ST=$ST/L=$L/O=$O/OU=$OU/CN=iwtm/emailAddress=$EMAIL" 2>/dev/null
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -extfile openssl.cnf -extensions server_cert -days 365 -passin pass:"$pass" -out server.crt 2>/dev/null
openssl pkcs12 -export -out bundle.pfx -inkey ca.key -in server.crt -in ca.crt -passout pass:"$pass" -passin pass:"$pass" 2>/dev/null
echo "xxXX1234" >> /opt/iw/tm5/etc/certification/pass.pass

cp /etc/nginx/conf.d/iwtm.conf /etc/nginx/conf.d/iwtm.conf.bak

openssl x509 -in server.crt -out server.pem -outform PEM
mv /ca/server.pem /opt/iw/tm5/etc/certification/web-server.pem
mv /ca/server.key /opt/iw/tm5/etc/certification/web-server.key
sed -i '/ssl_certificate_key/a ssl_password_file /opt/iw/tm5/etc/certification/pass.pass;' /etc/nginx/conf.d/iwtm.conf

# sed -i 's#ssl_certificate /opt/iw/tm5/etc/certification/web-server.pem;#ssl_certificate /ca/server.crt;#' /etc/nginx/conf.d/iwtm.conf
# sed -i 's#ssl_certificate_key /opt/iw/tm5/etc/certification/web-server.key;#ssl_certificate_key /ca/server.key;#' /etc/nginx/conf.d/iwtm.conf

rm -rf ca.* server.*
systemctl restart nginx
echo -e "THE SCRIPT HAS FINISHED ITS WORK. \n\nCOPY bundle.pfx TO 'demo.lab'"
echo -e "\n\nNE ZAPUSKAYTE SKRIPT NESKOLKO RAZ -- SLOMAETE VIRTUALKU\n\n"
