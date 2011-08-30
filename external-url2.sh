#!/bin/sh
mysql --default-character-set=utf8 -u root -B -D savemlak -e 'select externallinks.el_from, externallinks.el_to, page.page_title, page.page_namespace from externallinks, page where el_from = page.page_id' --skip-column-names
