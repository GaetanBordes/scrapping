require 'nokogiri'
require 'open-uri'


def scraper
  page = Nokogiri::HTML(URI.open("https://coinmarketcap.com/all/views/all/"))


  names = page.xpath('//tbody/tr/td[3]').map(&:text)
  prices = page.xpath('//tbody/tr/td[5]').map(&:text)


  cryptos = []

  names.each_with_index do |name, index|
    cryptos << {name: name, price: prices[index]}
  end 

  cryptos.first(20)
end

crypto_data = scraper

crypto_data.each do |crypto|
  puts "#{crypto[:name]} #{crypto[:price]}"
end