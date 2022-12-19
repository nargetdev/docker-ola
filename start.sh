#!/bin/bash

nohup olad &

ola_patch -d 1 -p 0 -u 1 -i

tail -f /dev/null