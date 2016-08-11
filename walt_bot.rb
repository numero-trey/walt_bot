require 'rubygems'
require 'bundler/setup'

require_relative "lib/walt_scraper"

require 'pp'

ws = WaltScraper::new

search_date = Date.new(2017,2,3) #Date.new(2016,9,8) #
results = ws.query_restaurant('Cinderellas Royal Table', search_date)

pp results
