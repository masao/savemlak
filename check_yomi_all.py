#!/usr/bin/python
# -*- coding: utf-8  -*-
"""

The following parameters are supported:

&params;

-dry              If given, doesn't do any real changes, but only shows
                  what would have been changed.

All other parameters will be regarded as part of the title of a single page,
and the bot will only work on that single page.
"""

import sys
import re

sys.path.append( "../pywikipedia/" )
import wikipedia as pywikibot
import pagegenerators

# This is required for the text that is shown when you run this script
# with the parameter -help.
docuReplacements = {
    '&params;': pagegenerators.parameterHelp
}

class CheckYomiAllBot:
    # Edit summary message that should be used.
    # NOTE: Put a good description here, and add translations, if possible!
    msg = {
        'en': u'Robot: Checking Yomi info within whole site',
        'ja':u'ロボットによる編集: check Yomi info within whole site',
    }

    def __init__(self):
        self.summary = pywikibot.translate(pywikibot.getSite(), self.msg)
        pywikibot.setAction( self.summary )

    def run(self, page):
        file = open( "check_yomi_all.txt" )
        text = file.read().decode("utf_8")
        if text != page.get():
            try:
                # Save the page
                page.put(text)
            except pywikibot.LockedPage:
                pywikibot.output(u"Page %s is locked; skipping."
                                 % page.title(asLink=True))
            except pywikibot.EditConflict:
                pywikibot.output(
                    u'Skipping %s because of edit conflict'
                    % (page.title()))
            except pywikibot.SpamfilterError, error:
                pywikibot.output(
                    u'Cannot change %s because of spam blacklist entry %s'
                    % (page.title(), error.url))

def main():
    bot = CheckYomiAllBot()
    page = pywikibot.Page( pywikibot.getSite(), u"利用者:Masao/Yomi_Check" )
    bot.run( page )

if __name__ == "__main__":
    try:
        main()
    finally:
        pywikibot.stopme()
