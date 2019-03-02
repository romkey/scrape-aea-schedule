# Scrape An Event Apart schedule into an iCalendar file

This is a quick and very, very dirty script which scrapes session info from [An Event Apart](https://aneventapart)'s web site and distills it into an iCal .ics file suitable for import into a calendar program.

I used this to generate a schedule for [An Event Apart Seattle 2019](https://aneventapart.com/event/seattle-2019). To use it for a different event, edit

## Running it

1. `git clone git@github.com:romkey/scrape-aea-schedule.git`
2. Make sure you have a working Ruby installed, preferably 2.6.1, and run `bundle install`
3. The web server at https://aneventapart.com is blocking direct downloads by the script, so manually download a copy of the HTML for https://aneventapart.com/event/seattle-2019 and save it as `seattle-2019.html`
3. Edit `scrape.rb` to update any of the constants at the top of the file as necessary
4. Run `bundle exec ./scrape.rb`
5. You should find a file called `aeasea2019.ics` (unless you changed its name in the constants); subscribe to thsi file or import this into your calendar and you should be all set. I've published a copy at https://romkey/aeasea2019.ics

## The Good

It's successful at scraping https://aneventapart.com/event/seattle-2018 and generating an iCal file that Apple and Google Calendar both like. It should work with schedules for other Event Apart locations as well.

## The Bad

It highly depends on the page layout and specific CSS selectors. A small change to the way the page is designed may well break the script.

## The Dirty

No testing whatsoever.

It has an issue with timezones. The schedule seems to not be pinned to a timezone and weird things may happen if your computer isn't set to Pacific time when you import or subscribe.

## License

This code is shared under the [MIT License](https://romkey.mit-license.org).
