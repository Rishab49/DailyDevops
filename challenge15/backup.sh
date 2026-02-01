#!/bin/bash

date=$(date +%d%m%Y)
filename=backup$date.sql
mysqldump --all-databases > $filename
gpg -c $filename
aws s3 cp $filename.gpg s3://rajrishab-backup