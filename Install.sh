#!/bin/bash
#Instala o Scada-LTS, Java8 e Tomcat7
#Marcos Jovair Botaro Junior
#marcos-botaro@hotmail.com
#24/04/2020 - Última atualização 24/04/2020


#[ ] FIREWALL
#[ ] Repositórios
#[X] Java
#[ ] MySQL
#[ ] Tomcat
#[ ] Scada-LTS

#Variaveis de sistema
##CORES(cores no padrão ansi)
vermelho="\033[1;31m"
azul="\033[1;34m"
NORMAL="\033[m"

#[ ] FIREWALL
#echo -e "${vermelho}Ativando o FIREWALL e abrindo a porta 8080:${NORMAL}"
#sudo ufw default deny incoming
#sudo ufw default allow outgoing
#sudo ufw allow ssh
#sudo ufw allow 22
#sudo ufw allow http
#sudo ufw allow 80
#sudo ufw allow 8080
#sudo ufw enable

#[ ] Repositórios
#Atualizar o sistema
echo -e "${azul}Atualizando a base de dados:${NORMAL}"
sudo apt update && sudo apt list --upgradable && sudo apt upgrade && sudo apt autoclean && sudo apt autoremove

#[X] Java
#Instala o Java 8
echo -e "${vermelho}Instalando o Java 8:${NORMAL}"
sudo apt install openjdk-8-jdk openjdk-8-jre
#Instalar LibRXTX-java
echo -e "${azul}Instalar LibRXTX-java:${NORMAL}"
sudo apt-get install librxtx-java
#Configura variaveis de ambiente
echo -e "${azul}Configurando as variaveis de ambiente:${NORMAL}"
sudo cat >> /etc/environment <<EOL
JAVA_HOME= /usr/lib/jvm/java-8-openjdk-amd64
JRE_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre
EOL

#[ ] MySQL


#[ ] Tomcat
#Cria o grupo TOMCAT
echo -e "${azul}Criando o grupo TOMCAT:${NORMAL}"
sudo groupadd tomcat
#Cria e configura o usuario TOMCAT
echo -e "${azul}Criando o usuario TOMCAT:${NORMAL}"
sudo useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat

#Download e instalação do TOMCAT
echo -e "${vermelho}Download e instalação do TOMCAT:${NORMAL}"
cd /tmp
sudo curl -O http://www.trieuvan.com/apache/tomcat/tomcat-7/v7.0.96/bin/apache-tomcat-7.0.96.tar.gz
sudo mkdir /opt/tomcat
sudo tar xzvf apache-tomcat-7.0.96.tar.gz -C /opt/tomcat --strip-components=1
cd /opt/tomcat
sudo chgrp -R tomcat /opt/tomcat
sudo chmod -R g+r conf
sudo chmod g+x conf
sudo chown -R tomcat webapps/ work/ temp/ logs/

#Configura variaveis de ambiente tomcat
echo -e "${azul}Configurando as variaveis de ambiente tomcat:${NORMAL}"
sudo cat >> /etc/systemd/system/tomcat.service <<EOL
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64/jre
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOL
sudo cat >> ~/.bashrc <<EOL
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
export CATALINA_HOME=/opt/tomcat/apache-tomcat-7.0.96
EOL
. ~/.bashrc

#[ ] Scada-LTS
