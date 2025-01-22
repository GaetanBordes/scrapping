require 'httparty'
require 'nokogiri'
require_relative '../lib/cryptos_scraper'

RSpec.describe 'CryptoScraper' do
  describe '#scrape_cryptos' do
    it 'returns a non-empty array of cryptos' do

      result = scrape_cryptos


      expect(result).to be_an(Array)
      expect(result).not_to be_empty
    end

    it 'contains hashes with valid symbols and prices' do
     
      result = scrape_cryptos


      result.each do |crypto|
        expect(crypto).to be_a(Hash)
        expect(crypto.keys.first).to be_a(String) 
        expect(crypto.values.first).to be_a(Float) 
        expect(crypto.values.first).to be > 0 
      end
    end
   it 'includes specific cryptos like Bitcoin and Ethereum' do
      result = scrape_cryptos
      symbols = result.map(&:keys).flatten
      expect(symbols).to include("BTC")
      expect(symbols).to include("ETH")
    end    
  end
end
