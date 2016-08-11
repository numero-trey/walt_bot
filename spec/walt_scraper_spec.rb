require_relative "../lib/walt_scraper"
require 'active_support/time'
require 'pp'

RSpec.describe WaltScraper do
  before(:context) do
    @ws = WaltScraper::new
  end

  context "Restaurants" do
    it "connects to WebDriver" do
      expect(@ws.connected?).to be true
    end
    # it "searches all availability" do
    #   search_date = Date.today + 175.days
    #   #puts search_date
    #   results = @ws.query_restaurants(search_date)
    #   #pp results
    #   expect(results.count).to be > 10
    #   expect(results.values.count).to be > 10
    # end
    it "searches individual availability" do
      search_date = Date.today + 175.days
      name = 'Cinderellas Royal Table'
      results = @ws.query_restaurant(name, search_date)
      expect(results.count).to be > 0
    end
  end
end
