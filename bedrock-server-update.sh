#!/bin/bash

MCSERVER_HOME=/home/mcserver/
MCSERVER_DOWNLOAD_ZIP=$MCSERVER_HOME/minecraft_bedrock/bedrock-server.zip
MCSERVER_INSTALL_PATH=$MCSERVER_HOME/minecraft_bedrock/
MCSERVER_PROP_BKUP_FILE=$MCSERVER_HOME/server.properties.bkup

echo "==== MINECRAFT BEDROCK SERVER AUTO UPDATE ===="

DOWNLOAD_URL=$(curl -H "Accept-Encoding: identity" -H "Accept-Language: en" -s -L -A "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; BEDROCK-UPDATER)" https://minecraft.net/en-us/download/server/bedrock/ |  grep -o 'https://minecraft.azureedge.net/bin-linux/[^"]*')
LATEST_VERSION=${DOWNLOAD_URL#*bedrock-server-}
LATEST_VERSION=${LATEST_VERSION%.zip}
if [ -e current_version.txt ]; then
    CURRENT_VERSION=$(cat current_version.txt)
fi
echo LATEST_VERSION=$LATEST_VERSION
echo CURRENT_VERSION=$CURRENT_VERSION

if [ $LATEST_VERSION = $CURRENT_VERSION ]; then
    echo "Current version is the latest. DONE!"
fi

set -e

echo "Start downloading ..."
sudo wget $DOWNLOAD_URL -O $MCSERVER_DOWNLOAD_ZIP

echo "Stopping server ..."
sudo systemctl stop mcbedrock

echo "Start installing ..."
sudo cp $MCSERVER_INSTALL_PATH/server.properties $MCSERVER_PROP_BKUP_FILE
sudo unzip -o $MCSERVER_DOWNLOAD_ZIP -d $MCSERVER_INSTALL_PATH
sudo rm $MCSERVER_DOWNLOAD_ZIP
sudo mv $MCSERVER_PROP_BKUP_FILE $MCSERVER_INSTALL_PATH/server.properties
sudo chown -R mcserver:mcserver $MCSERVER_HOME

echo "Restarting server ..."
sudo systemctl start mcbedrock

echo $LATEST_VERSION > current_version.txt
echo "DONE!"
