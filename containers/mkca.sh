#!/bin/sh
#
# Create a CA for testing
#
# Copyright (C) 2023 Simon Dobson
#
# This file is part of cloud-epydemic, network simulation as a service
#
# cloud-epydemic is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published byf
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# cloud-epydemic is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with cloud-epydemic. If not, see <http://www.gnu.org/licenses/gpl.html>.

# This is required to test RabbotMQ interactions with mTLS.
# See https://www.rabbitmq.com/ssl.html#manual-certificate-generation

# Files and directories
DIR="$1"
CA=`basename $DIR`

# Test whether the CA exists
if [ -d "$DIR" ]; then
    echo "CA already exists"
    exit 0
fi

# create the CA root
mkdir $DIR
cd $DIR
mkdir certs private
chmod 700 private
echo 01 > serial
touch index.txt

# Create the configuration file
cat >openssl.cnf <<EOF
[ ca ]
default_ca = $CA

[ $CA ]
certificate = $DIR/ca_certificate.pem
database = $DIR/index.txt
new_certs_dir = $DIR/certs
private_key = $DIR/private/ca_private_key.pem
serial = $DIR/serial

default_crl_days = 7
default_days = 365
default_md = sha256

policy = $CA_policy
x509_extensions = certificate_extensions

[ $CA_policy ]
commonName = supplied
stateOrProvinceName = optional
countryName = optional
emailAddress = optional
organizationName = optional
organizationalUnitName = optional
domainComponent = optional

[ certificate_extensions ]
basicConstraints = CA:false

[ req ]
default_bits = 2048
default_keyfile = $DIR/private/ca_private_key.pem
default_md = sha256
prompt = yes
distinguished_name = root_ca_distinguished_name
x509_extensions = root_ca_extensions

[ root_ca_distinguished_name ]
commonName = hostname

[ root_ca_extensions ]
basicConstraints = CA:true
keyUsage = keyCertSign, cRLSign

[ client_ca_extensions ]
basicConstraints = CA:false
keyUsage = digitalSignature,keyEncipherment
extendedKeyUsage = 1.3.6.1.5.5.7.3.2

[ server_ca_extensions ]
basicConstraints = CA:false
keyUsage = digitalSignature,keyEncipherment
extendedKeyUsage = 1.3.6.1.5.5.7.3.1
EOF

# Create CA root certificate and key
openssl req -x509 -config openssl.cnf \
	-newkey rsa:2048 -days 365 \
	-out ca_certificate.pem -outform PEM -subj /CN=$CA/ -nodes
openssl x509 -in ca_certificate.pem -out ca_certificate.cer -outform DER

# Create client and server certificates
for i in "client" "server"; do
    private_key="$i"_private_key.pem
    certificate_request="$i"_req.pem
    extensions="$i"_ca_extensions
    certificate="$i"_certificate.pem

    # certificate request
    openssl genrsa -out $private_key 2048
    openssl req -new -key $private_key -out $certificate_request -outform PEM \
	    -subj /CN=$(hostname)/O=$i/ -nodes

    # signed certificate
    openssl ca -config openssl.cnf -in $certificate_request \
	    -out $certificate -notext -batch -extensions $extensions

    # tidy up
    rm $certificate_request
done
