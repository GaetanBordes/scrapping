require 'httparty'
require 'nokogiri'

def scrape_cryptos
  response = HTTParty.get('https://coinmarketcap.com/')
  return [] unless response.code == 200

  cryptos = Nokogiri::HTML(response.body)
  crypto_rows = cryptos.css('table tbody tr')

  data = crypto_rows.map do |row|
    symbol_text = row.at_css('td:nth-child(3) a').text.strip rescue nil
    
    # trois dernières lettres comme le symbole pour eviter les erreurs 
    symbol = symbol_text[-3..-1] rescue nil 

    price = row.at_css('td:nth-child(4) span').text.strip.gsub(/[^\d.]/, '').to_f rescue nil

    { symbol => price } if symbol && price
  end

  data.compact
end

if __FILE__ == $PROGRAM_NAME
  result = scrape_cryptos
  puts result.inspect
end
