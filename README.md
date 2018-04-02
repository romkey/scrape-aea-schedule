# Scrape An Event Apart schedule into an iCalendar file

This is a quick and dirty - very dirty - script which scrapes session info from [An Event Apart](https://aneventapart)'s web site.

I used this to generate a schedule for [An Event Apart Seattle 2018](https://aneventapart.com/event/seattle-2018). To use it for a different event, edit

## Running it

1. `git clone git@github.com:romkey/scrape-aea-schedule.git`
2. Make sure you have a working Ruby installed, preferably 2.5.1, and run `bundle install`
3. Edit `scrape.rb` to update any of the constants at the top of the file as necessary
4. Run `bundle exec ./scrape.rb`
5. You should find a file called `aeasea2018.ics` (unless you changed its name in the constants); import this into your calendar and you should be all set.

## The Good

It's successful at scraping https://aneventapart.com/event/seattle-2018 and generating an iCal file that Apple and Google Calendar both like.

## The Bad

It highly depends on the page layout and specific CSS selectors. A small change to the way the page is designed may well break the script.

## The Dirty

No testing whatsoever.

It currently misses things like Happy Hour and registration times. I wanted to get these working but I also wanted to limit my time working on the script and not have it eat into my time watching talks during AEA.

