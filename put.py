#!/usr/bin/env python
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
import os
import re

sys.path.append( os.path.join( os.path.dirname(os.path.abspath(sys.argv[0])),
                               "..", "pywikipedia" ) )
sys.path.append( os.path.join( os.path.dirname(os.path.abspath(sys.argv[0])),
                               "..", "pywikibot" ) )
import pywikibot
from pywikibot import pagegenerators

# This is required for the text that is shown when you run this script
# with the parameter -help.
docuReplacements = {
    '&params;': pagegenerators.parameterHelp
}

class PagePutBot:
    # Edit summary message that should be used.
    # NOTE: Put a good description here, and add translations, if possible!
    msg = {
        'en': u'Robot: Put specified wikitext',
        'ja':u'ロボットによる編集: ウィキテキストの自動投稿',
    }

    def __init__(self, page, filename, summary, dry, always):
        self.page = pywikibot.Page( pywikibot.Site(), page )
        self.filename = filename
        self.summary = summary
        if not self.summary:
            self.summary = pywikibot.translate(pywikibot.getSite(), self.msg)
        # pywikibot.setAction( self.summary )

    def run(self):
        file = open( self.filename )
        text = file.read()
        try:
            current_text = self.page.get()
        except pywikibot.NoPage:
            current_text = None
        if current_text == None or text != current_text:
            try:
                # Save the page
                self.page.put(text)
            except pywikibot.exceptions.LockedPageError:
                pywikibot.output(u"Page %s is locked; skipping."
                                 % self.page.title(asLink=True))
            except pywikibot.exceptions.EditConflictError:
                pywikibot.output(
                    u'Skipping %s because of edit conflict'
                    % (self.page.title()))
            # except pywikibot.exceptions.SpamfilterError as error:
            #   pywikibot.output(
            #        u'Cannot change %s because of spam blacklist entry %s'
            #        % (self.page.title(), error.url))

def main():
    dry = None
    always = None
    page_title = None
    filename = None
    summary = None
    for arg in pywikibot.handle_args():
        if arg.startswith("-dry"):
            dry = True
        elif arg.startswith('-always'):
            always = True
        elif arg.startswith('-summary:'):
            summary = arg[len('-summary:'):]
        elif arg.startswith('-page:'):
            page_title = arg[len('-page:'):]
        elif arg.startswith('-file:'):
            filename = arg[len('-file:'):]

    bot = PagePutBot(page_title, filename, summary, dry, always)
    bot.run()

if __name__ == "__main__":
    try:
        main()
    finally:
        pywikibot.stopme()
