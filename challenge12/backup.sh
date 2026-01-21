#!/bin/bash

date=$(date +%u%m%Y)
filename=backup$date.sql
mysqldump --all-databases > $filename
gzip $filename