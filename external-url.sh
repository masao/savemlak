#!/bin/sh
mysql -u root -B -D savemlak -e 'select distinct el_to from externallinks;' --skip-column-names
