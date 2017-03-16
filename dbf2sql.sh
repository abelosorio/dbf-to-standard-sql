#!/bin/bash
#
# DBF to standard SQL converter
#

file=$1
output_dir=output

[ -d $output_dir ] || mkdir $output_dir

> $output_dir/input_files.sha
> $output_dir/output_files.sha

file_name=$( basename $file | sed -ne 's/\(.*\).DBF/\1/p' )
file_sql="$file_name".sql

## Compute the SHA
shasum $file >> $output_dir/input_files.sha

## Generate the CREATE TABLE
dbf_dump --info --SQL $file | \
  sed 's/create table \([^[:space:]]\+\)/CREATE TABLE "\1"/g' >> $output_dir/$file_sql

echo ';' >> $output_dir/$file_sql

## Generate the INSERTs
dbf_dump --info $file | tail -n +10 | sed -ne 's/^\([^[:space:]]\+\)[[:space:]]\+\([^[:space:]]\+\)[[:space:]]\+\([^[:space:]]\+\)[[:space:]]\+\([^[:space:]]\+\)[[:space:]]\+\([^[:space:]]\+\)$/\2/p' | xargs | sed -ne 's/[[:space:]]/,/g;s/\(.*\)/INSERT INTO '$file_name'(\1) VALUES /p' \
  >> $output_dir/$file_sql

## Generate the VALUEs
dbf_dump --undef NULL --fs '@@SEP@@' $file | \
  sed 's/@@SEP@@@@SEP@@/@@SEP@@NULL@@SEP@@/g' | \
  sed 's/^@@SEP@@/NULL@@SEP@@/g;s/@@SEP@@$/@@SEP@@NULL/g' | \
  sed "s/'/''/g" | \
  sed "s/@@SEP@@/', '/g;s/^/@@BEGIN@@('/g;s/$/')@@END@@/g;" | \
  sed "s/'NULL'/NULL/g" | \
  sed ':a;N;$!ba;s/\n/ /g' | \
  sed 's/@@END@@\s*@@BEGIN@@/, /g;s/@@BEGIN@@//g;s/@@END@@/;/g' \
    >> $output_dir/$file_sql

## Compute the SHA for CSV output
shasum $output_dir/$file_sql >> $output_dir/output_files.sha
