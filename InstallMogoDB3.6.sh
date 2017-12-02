#!/usr/bin/env bash

# Importa la clave pública usada por el sistema de gestión de paquetes
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5

# Crea la lista de ficheros para MongoDB
echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/testing multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list

# Actualiza la base de datos local de paquetes disponibles para Ubuntu
sudo apt-get update

# Instala los paquetes de MongoDB
sudo apt-get install -y mongodb-org

# Configura un servicio para que el servidor MongoDB se inicie en el arranque del sistema
sudo cp /vagrant/mongodb.service /etc/systemd/system/mongodb.service
sudo sed -i -e 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/gi' /etc/mongod.conf

# Inicia el servicio
sudo systemctl start mongodb
sudo systemctl status mongodb
sudo systemctl enable mongodb

