#!/bin/sh
mysql -u root -B -D savemlak -e 'select el_from, el_to from externallinks' --skip-column-names
