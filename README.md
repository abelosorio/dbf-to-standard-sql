# DBF to Standard SQL

## Requeriments

- Unix environment (we're using Bash, Sed, Grep, etc).
- libdbd-xbase-perl (`aptitude install libdbd-xbase-perl`).

## Installation

Just make sure you have the required tools:

```bash
$ sed --version | head -n 1
sed (GNU sed) 4.2.2

$ grep --version | head -n 1
grep (GNU grep) 2.20

$ dbf_dump --version
This is dbf_dump version 1.02.
```

## Usage

`dbf2sql.sh YOURFILE.DBF`

It will output the `CREATE TABLE` and `INSERT` statements to *Standard Output*.

## UTF-8 version

You can use the `dbf2sql_utf8.sh` to get the data in `UTF-8` codification.

`dbf2sql_utf8.sh YOURFILE.DBF`

You can *pipe* the output directly to your *SQL Engine*:

**PostgreSQL**
`dbf2sql_utf8.sh YOURFILE.DBF | psql YOUR_DB_NAME`

**MySQL**
`dbf2sql_utf8.sh YOURFILE.DBF | mysql -u YOUR_DB_USER YOUR_DB_NAME`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/abelosorio/dbf-to-standard-sql.