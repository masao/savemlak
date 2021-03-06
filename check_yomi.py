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

# This is required for the text that is shown when you run this script
# with the parameter -help.
docuReplacements = {
    '&params;': pagegenerators.parameterHelp
}

class CheckYomiBot:
    # Edit summary message that should be used.
    # NOTE: Put a good description here, and add translations, if possible!
    msg = {
        'en': u'Robot: Checking Yomi info',
        'ja':u'ロボットによる編集: check Yomi field',
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
        for page in self.generator:
            self.treat(page)
        if self.outputwiki:
            for page in sorted(set(self.count["target"])-set(self.count["done"])):
                print( (u"*%s" % page).encode('utf_8') )
        print "Done: %.01f%% (%d/%d)" % \
              ( 100*len(self.count["done"]) / float(len(self.count["target"])),
                len(self.count["done"]),
                len(self.count["target"]),
              )

    def treat(self, page):
        """
        Loads the given page, does some changes, and saves it.
        """
        text = self.load(page)
        if not text:
            return

	self.count[ "target" ].append( page.title(asLink=True) )
	pattern = re.compile( ur'\|\s*よみ\s*=([^\n]*\n)' )
	match = pattern.search( text )
	#print match.group(1)
	if match == None or len(match.group(1).strip()) == 0:
            if self.input:
                yomi = raw_input( 'Yomi for %s? ' % page.title().encode('utf_8') )
                yomi = yomi.strip()
                if len( yomi ) > 0:
		    if match:
                        text = re.sub( pattern, ur'|よみ=%s\n' % yomi.decode('utf_8'), text )
                    else:
                    	tmpl_pattern = re.compile( ur'{{(図書館|博物館|文書館|施設)(.+?)}}',
                                                   re.DOTALL )
                        text = re.sub( tmpl_pattern,
                                       ur'{{\1\n|よみ=%s\2}}' % yomi.decode('utf_8'),
                                       text )
                else:
                    return
            else:
                return

	if pattern.search( text ):
	    #print "%s done." % page.title(asLink=True)
	    self.count[ "done" ].append( page.title(asLink=True) )
	else:
            return

        if self.outputwiki:
            return
        
        # Munge!
        text = re.sub( r'\[\[Category:(.+?)\|.*?\]\]',
                       r'[[Category:\1]]',
                       text )

        # only save if something was changed
        if text != page.get():
            # Show the title of the page we're working on.
            # Highlight the title in purple.
            pywikibot.output(u"\n\n>>> %s <<<" % page.title())
            # show what was changed
            pywikibot.showDiff(page.get(), text)
            if not self.dry:
                if not self.always:
                    choice = pywikibot.inputChoice(
                        u'Do you want to accept these changes?',
                        ['Yes', 'No'], ['y', 'N'], 'N')
                else:
                    choice = 'y'
                if choice == 'y':
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
        bot = CheckYomiBot(gen, dry, always, input, outputwiki)
        bot.run()
    else:
        pywikibot.showHelp()

if __name__ == "__main__":
    try:
        main()
    finally:
        pywikibot.stopme()
