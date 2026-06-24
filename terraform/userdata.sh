#!/bin/bash

apt update -y

apt install -y curl wget git

curl -sfL https://get.k3s.io | sh -

systemctl enable k3s

systemctl start k3s