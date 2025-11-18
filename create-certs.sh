set -euo pipefail
export MSYS_NO_PATHCONV=1
trap 'echo "Error on line $LINENO. Press Enter to continue..."; read' ERR

#CA
createCA=1

if [ "$createCA" -eq 1 ];then
    echo "creating CA cert"
	# this one takes 4ever
	# 1234
    echo "creating CA cert key"
	openssl genrsa -out CA.key 4096
    echo "creating CA cert csr"
	
	openssl req -new -key CA.key -out CA.csr -subj '/C=US/ST=Example State/L=Example City/O=Example Organization/OU=Root CA/CN=Root CA'
    echo "creating CA cert crt"
	
	openssl req -x509 -new -key CA.key -out CA.crt -days 3650 \
		-subj "/C=US/ST=Example State/L=Example City/O=Example Organization/OU=Root CA/CN=Root CA" \
		-extensions v3_ca \
		-config ca.cnf
	
    echo "creating CA done"
fi

echo "creating localhost(server) cert"
echo "creating localhost(server) csr"

#Website CRT
openssl req -new -nodes -out localhost.csr -newkey rsa:4096 -keyout localhost.key -subj '/CN=My Firewall/C=AT/ST=Vienna/L=Vienna/O=MyOrg'
echo "creating localhost(server) crt"
openssl x509 -req \
  -CA ./CA.crt    \
  -CAkey ./CA.key \
  -in localhost.csr    \
  -out localhost.crt    \
  -days 365000          \
  -CAcreateserial    \
  -extfile cnf_extfile.cnf
  
  
  # client
  
  #pw:test123
  
echo "creating client cert"
echo "creating client key"
openssl genpkey -algorithm RSA -out client.key
  
echo "creating client csr"
openssl req -new -key client.key -out client.csr \
	-reqexts req_ext \
	-config config.cnf
  
echo "creating client crt"
openssl x509 -req -in client.csr -CA CA.crt -CAkey CA.key -CAcreateserial -out client.crt -days 365 -extfile config.cnf -extensions req_ext

echo "creating client crt/key bundle"
openssl pkcs12 -export -out client.p12 -inkey client.key -in client.crt -certfile CA.crt -passout pass:123
 
echo "1. install CA.crt as trusted certificate authority"
echo "2. install client.p12 (password 123) as standard certificate"
echo "3. open browser to https://localhost"

echo "... done"
read
  
  
