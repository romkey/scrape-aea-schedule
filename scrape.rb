#!/usr/bin/env ruby
require 'nokogiri'
require 'open-uri'
require 'icalendar'
require 'date'
require 'pp'

URL = 'https://aneventapart.com/event/seattle-2018'
STARTING_DAY = Date.new(2018, 4, 2)
TIMEZONE = "-0900"
FILENAME = './seattle-2018.html'
OUTPUT_FILENAME = 'aeasea2018.ics'

def find_sessions(html)
  parsed = Nokogiri::HTML(html)
  
  li_s = parsed.css('.single-session')

  session_struct = Struct.new :name, :speaker, :speaker_link, :speaker_org, :start, :end, :description

  current_day = STARTING_DAY

  sessions = []
  li_s.each do |li|
    session = session_struct.new
    time = li.css('time')
    next unless time

    # get the event time
    # notice if it's tomorrow and increment the current day
    times = time[0].text.split('-')
    next unless times.length == 2

    session.start = DateTime.parse "#{current_day} #{times[0]} #{TIMEZONE}"
    if sessions.last && (sessions.last.start > session.start)
      current_day += 1
      session.start = DateTime.parse "#{current_day} #{times[0]} #{TIMEZONE}"
    end
    session.end = DateTime.parse "#{current_day} #{times[1]} #{TIMEZONE}"


    speaker = li.css('.speaker-link')[0]
    if speaker
      session.speaker = speaker.text
      session.speaker_link = speaker['href']
    end

    org = li.css('.byline-title')[0]
    if org
      session.speaker_org = org.text
    end

    name = li.css('h2.toggled')[0]
    if name
      session.name = name.text
      if session.name == 'Lunch'
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
