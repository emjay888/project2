#!/bin/sh
nohup kubectl port-forward svc/myfirstdevopsservice 30000:80 --address='0.0.0.0' &
# kubectl port-forward --address 0.0.0.0 svc/myfirstdevopsservice 30000:80 &