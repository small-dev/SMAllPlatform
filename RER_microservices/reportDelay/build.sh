#!/bin/bash

echo "constants{BUSETA=\"socket://buseta:9006\"}" > busEtaAddress.iol
docker build -t report_delay .