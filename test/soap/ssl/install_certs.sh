#!/usr/bin/env bash

echo "this script does not work;"
echo "the ssl test does not work either"
exit

rm myCA -fr
conf=../openssl.my.cnf

mkdir -m 0755 ./myCA ./myCA/private ./myCA/certs ./myCA/newcerts ./myCA/crl
pushd ./myCA > /dev/null
touch ./index.txt
 echo '01' > ./serial

#create the server private key
openssl req -config $conf -new -x509  -keyout ./private/server.key -out ./certs/server.crt -days 1825
#create the CA certificate and key
openssl req -config $conf -new -x509  -keyout ./private/ca.key -out ./certs/ca.crt -days 1825
#create the certificate request
openssl req -config $conf -new -nodes -keyout ./private/server.key -out ./server.csr -days 365
#sign the certificate request
openssl ca -config $conf -policy policy_anything -out certs/ca.cert -infiles ./server.csr
 rm -f ./server.csr
#verify the cert
 openssl x509 -subject -issuer -enddate -noout -in ./certs/ca.crt
popd > /dev/null

#chmod 0400 ./myCA/private/server.key
# chown root.apache /etc/pki_jungle/myCA/private/server.key
# chmod 0440 /etc/pki_jungle/myCA/private/server.key