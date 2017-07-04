#!/bin/bash
#
# DBF to standard SQL converter
#
# Usage:
#
#   dbf2sql.sh YOURFILE.DBF > YOURFILE.SQL
#

file=$1

file_name=$( basename $file | sed -ne 's/\(.*\).DBF/\1/p' )

## Generate the CREATE TABLE
dbf_dump --info --SQL $file | \
  # Add "" to table name for names that start with numbers.
  sed 's/create table \([^[:space:]]\+\)/CREATE TABLE "\1"/g' | \
  # Replace invalid SQL data types
  sed 's/date([0-9]\+)/date/g' | \
  sed 's/boolean(1)/boolean/g'

echo ';'

## Generate the INSERTs
insert_sentence=$( dbf_dump --info $file | \
  # Filter for columns detail
  grep '^[0-9]\+\.' | \
  # Generate INSERT statements
  sed -ne 's/^\([^[:space:]]\+\)[[:space:]]\+\([^[:space:]]\+\)[[:space:]]\+\([^[:space:]]\+\)[[:space:]]\+\([^[:space:]]\+\)[[:space:]]\+\([^[:space:]]\+\)$/\2/p' | \
  xargs | \
  sed -ne 's/[[:space:]]/,/g;s/\(.*\)/INSERT INTO "'$file_name'"(\1) VALUES /p' )

## Generate the VALUEs
dbf_dump --undef NULL --fs '@@SEP@@' $file | \
  sed 's/@@SEP@@@@SEP@@/@@SEP@@NULL@@SEP@@/g' | \
  sed 's/^@@SEP@@/NULL@@SEP@@/g;s/@@SEP@@$/@@SEP@@NULL/g' | \
  sed "s/'/''/g" | \
  sed "s/@@SEP@@/', '/g;s/^/@@BEGIN@@('/g;s/$/')@@END@@/g;" | \
  sed "s/'NULL'/NULL/g" | \
  sed "s/@@BEGIN@@/$insert_sentence/g;s/@@END@@/;/g"
