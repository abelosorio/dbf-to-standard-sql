#!/bin/bash

./dbf2sql.sh $1 | iconv -ct utf8//TRANSLIT
