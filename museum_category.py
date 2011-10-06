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
import re

sys.path.append( "../pywikipedia/" )
import wikipedia as pywikibot
import pagegenerators
import catlib

# This is required for the text that is shown when you run this script
# with the parameter -help.
docuReplacements = {
    '&params;': pagegenerators.parameterHelp
}

class MuseumCategoryBot:
    # Edit summary message that should be used.
    # NOTE: Put a good description here, and add translations, if possible!
    msg = {
        'en': u'Robot: Listing museum category',
        'ja':u'ロボットによる編集: 博物館カテゴリ情報のリスト化',
    }

    def __init__(self, generator, dry, always, input, outputwiki):
        """
        Constructor. Parameters:
            @param generator: The page generator that determines on which pages
                              to work.
            @type generator: generator.
            @param dry: If True, doesn't do any real changes, but only shows
                        what would have been changed.
            @type dry: boolean.
        """
        self.generator = generator
        self.dry = dry
        self.always = always
        self.input = input
        self.outputwiki = outputwiki
        # Set the edit summary message
        self.summary = pywikibot.translate(pywikibot.getSite(), self.msg)

    def run(self):
    	self.count = { "target" : [], "done" : [] }
        pywikibot.setAction( self.summary )
        musecat = catlib.Category( pywikibot.getSite(), u'Category:博物館' )
        ignore_list = [
            catlib.Category( pywikibot.getSite(), u'Category:登録博物館' ),
            catlib.Category( pywikibot.getSite(), u'Category:博物館相当施設' ),
            catlib.Category( pywikibot.getSite(),  u'Category:全国博物館園職員録' ),
            catlib.Category( pywikibot.getSite(), u'Category:全国博物館総覧' ),
        ]
        catlist = musecat.subcategoriesList()
        catlist = set( catlist ) - set( ignore_list )
        for page in self.generator:
            self.treat(page, catlist)

    def treat(self, page, categorylist):
        """
        Loads the given page, does some changes, and saves it.
        """
        if page.isRedirectPage():
            return
        #pywikibot.output( "-%s" % page.title() )
        cats = page.categories(get_redirect=True)
        #for cat in cats:
        #    pywikibot.output( "-%s" %  cat )
        for cat in categorylist:
            if cat in cats:
                return

        pagetitle = page.title(asLink=True)
        othercats = u", ".join( map((lambda e: e.aslink(textlink=True)),
                                    cats) )
        print (u"*%s <small>%s</small>" % (pagetitle, othercats)).encode('utf_8')

    def load(self, page):
        """
        Loads the given page, does some changes, and saves it.
        """
        try:
            # Load the page
            text = page.get()
        except pywikibot.NoPage:
            pywikibot.output(u"Page %s does not exist; skipping."
                             % page.title(asLink=True))
        except pywikibot.IsRedirectPage:
            pywikibot.output(u"Page %s is a redirect; skipping."
                             % page.title(asLink=True))
        else:
            return text
        return None

def main():
    # This factory is responsible for processing command line arguments
    # that are also used by other scripts and that determine on which pages
    # to work on.
    genFactory = pagegenerators.GeneratorFactory()
    # The generator gives the pages that should be worked upon.
    gen = None
    # This temporary array is used to read the page title if one single
    # page to work on is specified by the arguments.
    pageTitleParts = []
    # If dry is True, doesn't do any real changes, but only show
    # what would have been changed.
    dry = False
    # will become True when the user uses the -always flag.
    always = False
    # will input Yomi data
    input = False
    # will input Yomi data
    outputwiki = False

    # Parse command line arguments
    for arg in pywikibot.handleArgs():
        if arg.startswith("-dry"):
            dry = True
        elif arg.startswith("-always"):
            always = True
        elif arg.startswith("-input"):
            input = True
        elif arg.startswith("-outputwiki"):
            outputwiki = True
        else:
            # check if a standard argument like
            # -start:XYZ or -ref:Asdf was given.
            if not genFactory.handleArg(arg):
                pageTitleParts.append(arg)

    if pageTitleParts != []:
        # We will only work on a single page.
        pageTitle = ' '.join(pageTitleParts)
        page = pywikibot.Page(pywikibot.getSite(), pageTitle)
        gen = iter([page])

    if not gen:
        gen = genFactory.getCombinedGenerator()
    if gen:
        # The preloading generator is responsible for downloading multiple
        # pages from the wiki simultaneously.
        gen = pagegenerators.PreloadingGenerator(gen)
        bot = MuseumCategoryBot(gen, dry, always, input, outputwiki)
        bot.run()
    else:
        pywikibot.showHelp()

if __name__ == "__main__":
    try:
        main()
    finally:
        pywikibot.stopme()
