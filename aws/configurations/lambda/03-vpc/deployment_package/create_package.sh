#!/bin/bash


mkdir dependencies
pip install requests --target ./dependencies
cd dependencies
zip -r ../deployment_package.zip .
cd ../
zip deployment_package.zip lambda.py
