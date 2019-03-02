#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'icalendar'
require 'date'
require 'icalendar/tzinfo'
require 'pp'

URL = 'https://aneventapart.com/event/seattle-2019'
STARTING_DAY = Date.new(2019, 3, 4)
TIMEZONE = 'America/Los_Angeles'
FILENAME = './seattle-2019.html'
OUTPUT_FILENAME = 'aeasea2019.ics'
LOCATION = 'Westin, 1900 5th Ave., Seattle'

def find_sessions(html)
  parsed = Nokogiri::HTML(html)
  
  #  li_s = parsed.css('.has-session-info')
  li_s = parsed.css('.sessions li')

  session_struct = Struct.new :name, :speaker, :speaker_link, :speaker_org, :start, :end, :description, :location

  current_day = STARTING_DAY

  sessions = []
  li_s.each do |li|
    session = session_struct.new
    session.location = LOCATION

    time = li.css('time')
    next unless time

    # get the event time
    # notice if it's tomorrow and increment the current day
    times = time[0].text.split('-')
    next unless times.length == 2

    session.start = DateTime.parse "#{current_day} #{times[0]} PST"
    if sessions.last && (sessions.last.start > session.start)
      current_day += 1
      session.start = DateTime.parse "#{current_day} #{times[0]} PST"
    end
    session.end = DateTime.parse "#{current_day} #{times[1]} PST"

    speaker = li.css('.speaker-link')[0]
    if speaker
      session.speaker = speaker.text
      session.speaker_link = speaker['href']
    end

    org = li.css('.byline-title')[0]
    if org
      session.speaker_org = org.text
    end

    name = li.css('h4')[0]
    if name
      session.name = name.text

      if ['Lunch ', 'Breakfast', 'Morning Welcome', 'Attendee Check-in/Badge Pick-up', 'Happy Hour'].include?(session.name) || session.name.include?('Special Screening')
        session.speaker = ''
        session.speaker_org = ''
        session.speaker_link = ''
      end
    end

    next unless session.name && session.speaker

    if li.css('.session-extended')[0]
      session[:description] = li.css('.session-extended')[0].text
    end

    sessions.push session
  end

  sessions
end

if File.exists? FILENAME
  html = File.read FILENAME
else
  html = open URL
  File.open(FILENAME, 'w') { |f| f.write(html) }
end

cal = Icalendar::Calendar.new

#tz = TZInfo::Timezone.get 'America/Los_Angeles'
#timezone = tz.ical_timezone Time.now

cal.timezone do |t|
  t.tzid = TIMEZONE

  t.daylight do |d|
    d.tzoffsetfrom = "-0800"
    d.tzoffsetto   = "-0700"
    d.tzname       = "PDT"
    d.dtstart      = "19700308T020000"
    d.rrule        = "FREQ=YEARLY;BYMONTH=3;BYDAY=2SU"
  end

  t.standard do |s|
    s.tzoffsetfrom = "-0700"
    s.tzoffsetto   = "-0800"
    s.tzname       = "PST"
    s.dtstart      = "19701101T020000"
    s.rrule        = "FREQ=YEARLY;BYMONTH=11;BYDAY=1SU"
  end
end


find_sessions(html).each do |session|
  next unless session.name

  cal.event do |e|
    e.dtstart = session.start
    e.dtend = session.end
    if session.speaker == ''
      e.summary = session.name
    else
      e.summary = "#{session.name} / #{session.speaker}"
    end      
    if session.speaker_link
      e.url = 'https://aneventapart.com' + session.speaker_link
    end
    e.description = session.description
  end
end

File.open(OUTPUT_FILENAME, 'w') { |f| f.write(cal.to_ical) }
