## This script was tested using Python 2.7.9
## The MWClient library was used to access the api.  It can be found at:
## https://github.com/mwclient/mwclient

import mwclient
site = mwclient.Site(('https', 'en.wikipedia.org'))
site.login('$user', '$pass') # credentials are sanitized from the script.
listpage = site.Pages['User:$user/World_of_Warcraft'] # page is sanitized.
text = listpage.text()
for page in site.Categories['World_of_Warcraft']:
    text += "* [[:" + page.name + "]]\n"
listpage.save(text, summary='Creating list from [[Category:World_of_Warcraft]]')

## results are found at:
## https://en.wikipedia.org/wiki/User:Jebaile7964/World_of_Warcraft
