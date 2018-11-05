#!/bin/bash

# Install all that is required to use a monome device on a vanilla bela board,
# start the serialosc daemon on boot using systemd.
# Requires an internet connection to use apt and git.

git clone https://github.com/monome/libmonome.git
sudo apt install libudev-dev liblo-dev libavahi-compat-libdnssd-dev
cd libmonome
./waf configure
./waf
sudo ./waf install
cd ..
git clone https://github.com/monome/serialosc.git
cd serialosc
git submodule init
git submodule update
./waf configure
./waf
sudo ./waf install
cd ..

cat << EOF > serialoscd.service
[Unit]
Description=simple
[Service]
Type=forking
ExecStart=serialoscd
PIDFile=/var/run/serialoscd.pid
RemainAfterExit=no
Restart=on-failure
RestartSec=5s
[Install]
WantedBy=multi-user.target
EOF

chmod 777 serialoscd.service
mv serialoscd.service /lib/systemd/system/serialoscd.service
ln -s /lib/systemd/system/serialoscd.service /etc/systemd/system/multi-user.target.wants/serialoscd.service
ldconfig
