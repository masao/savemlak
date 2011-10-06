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
import urllib

try:
    import simplejson as json
except ImportError:
    import json

sys.path.append( "../pywikipedia/" )
import wikipedia as pywikibot
import pagegenerators

# This is required for the text that is shown when you run this script
# with the parameter -help.
docuReplacements = {
    '&params;': pagegenerators.parameterHelp
}

class GeocodingOverQueryLimitError(Exception):
    """class for exceptions if RateLimit over in Google Geocoding API."""
    pass

class GeocodeBot:
    # Edit summary message that should be used.
    # NOTE: Put a good description here, and add translations, if possible!
    msg = {
        'en': u'Robot: Geocoding',
        'ja':u'ロボットによる編集: 緯度経度の自動取得',
    }

    def __init__(self, generator, dry, always):
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
        # Set the edit summary message
        self.summary = pywikibot.translate(pywikibot.getSite(), self.msg)

    def run(self):
        pywikibot.setAction( self.summary )
        for page in self.generator:
            self.treat(page)

    def treat(self, page):
        """
        Loads the given page, does some changes, and saves it.
        """
        text = self.load(page)
        if not text:
            return

	pattern_coordinates = re.compile( ur'\s*\|\s*緯度経度\s*=([^\n]*)\n' )
        match_coordinates = pattern_coordinates.search( text )
        if match_coordinates:
            val = match_coordinates.group( 1 ).strip()
            #print val
            if len(val) == 0 or re.match( ur'^0\s*,\s*0$', val ):
                text = re.sub( pattern_coordinates, r'\n', text )
            else:
                return

        pattern_address = re.compile( ur'\|\s*所在地\s*=([^\|]*)' )
        match_address = pattern_address.search( text )
        if not match_address or len(match_address.group(1).strip()) == 0:
	    line = u"*%s (所在地 記載なし)" % page.title(asLink=True)
            print line.encode('utf_8')
            return
        address = match_address.group( 1 ).strip()
        #print address

        latlng = None
        try:
            latlng = self.geocoding( address )
            if not latlng:
                address2 = re.sub( ur'^〒?\d\d\d-?(\d\d\d\d)?\s*', "", address )
                if address != address2:
                    pywikibot.output( address2 )
                    latlng = self.geocoding( address2 )
                if not latlng:
                    address_noparen = re.sub( ur'\([^\)]+\)$', "", address2 )
                    address_noparen = re.sub( ur'（[^）]+）$', "", address2 )
                    if address_noparen != address2:
                        pywikibot.output( address_noparen )
                        latlng = self.geocoding( address_noparen )
                if not latlng:
                    address_nobuilding = re.sub( ur'[0-9０-９\.,・、]+\s*[F階]$', "", address_noparen )
                    address_nobuilding = re.sub( ur'[^0-9０-９]*$', "", address_nobuilding )
                    if address_nobuilding != address_noparen and address_nobuilding != "":
                        pywikibot.output( address_nobuilding )
                        latlng = self.geocoding( address_nobuilding )
        except GeocodingOverQueryLimitError:
            pywikibot.output( u"OVER_QUERY_LIMIT error at %s." % page.title(asLink=True) )
        if not latlng:
	    line = "*%s (%s)" % ( page.title(asLink=True), address.strip() )
            print line.encode('utf_8')
            return

        text = re.sub( pattern_address,
                       ur'\g<0>|緯度経度=%s,%s\n' % ( latlng["lat"], latlng["lng"] ),
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

    def geocoding(self, address):
        url = 'http://maps.google.com/maps/api/geocode/json?'
        url = url + '&language=ja&sensor=false&region=ja'
        url = url + '&address=' + urllib.quote(address.encode('utf-8'))
        io = urllib.urlopen( url )
        content = io.read()
        #print "%s" % content
        obj = json.loads(content)
        if obj["status"] == "OVER_QUERY_LIMIT":
            raise GeocodingOverQueryLimitError( u'Geocoding "OVER_QUERY_LIMIT" error for %s.' % address )
        elif obj["status"] != "OK":
            return None

        result = {}
        result['lng'] = str(obj["results"][0]["geometry"]["location"]["lng"])
        result['lat'] = str(obj["results"][0]["geometry"]["location"]["lat"])
        return result

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
        bot = GeocodeBot(gen, dry, always)
        bot.run()
    else:
        pywikibot.showHelp()

if __name__ == "__main__":
    try:
        main()
    finally:
        pywikibot.stopme()
