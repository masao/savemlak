# -*- coding: utf-8  -*-

import family

# SaveMLA wiki

class Family(family.Family):
    def __init__(self):
        family.Family.__init__(self)

        self.name = 'savemla'

        self.langs = {
                'ja': 'savemla.jp',
        }
        self.namespaces[1] = {
            'ja': u'トーク',
        }
        self.namespaces[2] = {
            'ja': u'利用者',
        }
        self.namespaces[3] = {
            'ja': u'利用者・トーク',
        }
        self.namespaces[4] = {
            'ja': u'SaveMLA',
        }
        self.namespaces[5] = {
            'ja': u'SaveMLA・トーク',
        }
        self.namespaces[6] = {
            'ja': u'ファイル',
        }
        self.namespaces[7] = {
            'ja': u'ファイル・トーク',
        }

    def version(self, code):
        return "1.18alpha"

    def scriptpath(self, code):
        return '/savemla'
