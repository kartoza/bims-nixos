#!/usr/bin/env bash

sudo nixos-rebuild switch \
  --flake .#robot 
  #--target-host root@37.27.227.42 
  #--build-host root@37.27.227.42 \
  #--use-remote-sudo

