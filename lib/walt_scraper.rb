require 'rubygems'
require 'bundler/setup'

require "selenium-webdriver"

class WaltScraper
  RESTAURANT_URL = "https://disneyworld.disney.go.com/dining/magic-kingdom/"
  RESTAURANTS_URL = "https://disneyworld.disney.go.com/dining/#/reservations-accepted"

  MEALS = {
    breakfast: 0,
    lunch: 1,
    dinner: 2
  }

  @web_driver = nil

  def initialize(opts = {})
    opts = {
      webdriver_host: "http://localhost:8910"
    }.merge(opts)

    @web_driver = Selenium::WebDriver.for(:remote, :url => opts[:webdriver_host])
    ObjectSpace.define_finalizer(self, proc { @web_driver.close } )
  end

  def wait_for_results(timeout = 10)
    raise "No webdriver connection" unless self.connected?

    loop_time = 0.2
    timer = 0.0
    status = :pre
    while timer < timeout.to_f && status != :done
      indicator = @web_driver.find_elements(class: 'updatingIndicator')
      if status == :pre
        status = :waiting if indicator.any? && indicator[0].displayed?
      elsif status == :waiting
        status = :done if !indicator[0].displayed?
        next
      end
      sleep(loop_time)
      timer += loop_time
    end
  end

  def query_restaurants(date)
    query_meal(WaltScraper::Meals::LUNCH, date)
  end

  def query_meal(meal, date)
    raise "No webdriver connection" unless self.connected?
    @web_driver.navigate.to RESTAURANTS_URL

    @web_driver.execute_script("$('input[name=searchDate]').val('#{date.strftime('%m/%d/%Y')}')")
    @web_driver.execute_script("$('select[name=searchTime]').val('#{Meals::LUNCH}')")
    @web_driver.find_element(id: 'searchButton').click
    wait_for_results()

    @web_driver.find_elements(css: '.cardLink').inject({}) do |res, avail|
      name = avail['aria-label'].gsub(/[^0-9a-z ]/i, '')
      times = avail.find_elements(css: '.offerButton .buttonText').collect(&:text)
      res[name] = times
      res
    end

  end

  def screenshot
    puts "Saving Screenshot"
    @web_driver.save_screenshot('test.png')
  end

  def query_restaurant(name, date)
    @web_driver.navigate.to RESTAURANT_URL + 'cinderella-royal-table/'

    @web_driver.execute_script("$('input[name=searchDate]').val('#{date.strftime('%m/%d/%Y')}')")
    # @web_driver.find_element(id: 'searchTime-wrapper').click
    # sleep(1)
    # @web_driver.find_element(css: '#diningAvailabilityForm-searchTime-1 span').click
    @web_driver.execute_script("$('select[name=searchTime]').val('#{Meals::LUNCH}')")
    @web_driver.find_element(name: 'findTableButton').click
    wait_for_results()
    #avail = @web_driver.execute_script("return $('#diningAvailabilityFlag').data()['hasavailability']") == 1

    @web_driver.find_elements(css: '.offerButton .buttonText').collect(&:text)
  end

  def connected?
    @web_driver != nil
  end

  class Meals
    BREAKFAST = 80000712
    LUNCH = 80000717
    DINNER = 80000714
  end


end
