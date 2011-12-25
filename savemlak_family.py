# -*- coding: utf-8  -*-

import family

# SaveMLA wiki

class Family(family.Family):
    def __init__(self):
        family.Family.__init__(self)

        self.name = 'savemlak'

        self.langs = {
                'ja': 'savemlak.jp',
                'en': 'savemlak.jp',
        }
	self.nocapitalize = [ 'ja', 'en' ]
        self.namespaces[1] = {
            'ja': u'トーク',
        }
        self.namespaces[2] = {
            'ja': u'利用者',
            'en': u'利用者',
        }
        self.namespaces[3] = {
            'ja': u'利用者・トーク',
        }
        self.namespaces[4] = {
            'ja': u'saveMLAK',
        }
        self.namespaces[5] = {
            'ja': u'saveMLAK・トーク',
        }
        self.namespaces[6] = {
            'ja': u'ファイル',
        }
        self.namespaces[7] = {
            'ja': u'ファイル・トーク',
        }
        self.namespaces[102] = {
            'ja': u'Property',
        }
        self.namespaces[103] = {
            'ja': u'Property talk',
        }
        self.namespaces[104] = {
            'ja': u'Type',
        }
        self.namespaces[105] = {
            'ja': u'Type talk',
        }
        self.namespaces[106] = {
            'ja': u'Form',
        }
        self.namespaces[107] = {
            'ja': u'Form talk',
        }
        self.namespaces[108] = {
            'ja': u'Concept',
        }
        self.namespaces[109] = {
            'ja': u'Concept talk',
        }
        self.namespaces[274] = {
            'ja': u'Widget',
        }
        self.namespaces[275] = {
            'ja': u'Widget talk',
        }
        self.namespaces[420] = {
            'ja': u'Layer',
        }
        self.namespaces[421] = {
            'ja': u'Layer talk',
        }

    def version(self, code):
        return "1.18alpha"

    def scriptpath(self, code):
        return '/savemlak'
