#!/bin/bash


mkdir python
pip install requests --target ./python
zip -r layer.zip python/
