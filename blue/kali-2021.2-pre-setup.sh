#!/bin/bash
apt update -y
apt install ansible -y

ansible-playbook ./kali-2021.02-setup.yml --ask-become-pass
