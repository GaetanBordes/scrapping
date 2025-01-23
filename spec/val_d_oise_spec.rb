require 'rspec'
require 'nokogiri'
require 'http'
require_relative '../lib/val_d_oise' 

RSpec.describe 'Townhall Scraper' do
  describe '#get_townhall_urls' do
    it 'returns an array of URLs for townhalls in Val-d’Oise' do
      urls = get_townhall_urls
      expect(urls).to be_an(Array)
      expect(urls).not_to be_empty
      expect(urls.all? { |url| url.start_with?('https://lannuaire.service-public.fr') }).to be true
    end
  end

  describe '#get_townhall_emails' do
    let(:mock_urls) do
      [
        'https://lannuaire.service-public.fr/navigation/ile-de-france/val-d-oise/mairie/avernes',
        'https://lannuaire.service-public.fr/navigation/ile-de-france/val-d-oise/mairie/argenteuil'
      ]
    end

    it 'returns an array of hashes with town names and their emails' do
      allow(HTTP).to receive(:get).and_return(
        double(
          body: <<-HTML
            <html>
              <body>
                <div id="contentContactEmail">
                  <span>Contact Email: </span><a href="mailto:mairie@example.com">mairie@example.com</a>
                </div>
                <h1>Mairie d'Avernes</h1>
              </body>
            </html>
          HTML
        )
      )

      emails = get_townhall_emails(mock_urls)
      expect(emails).to be_an(Array)
      expect(emails.first).to eq({ "Mairie d'Avernes" => 'mairie@example.com' })
    end

    it 'skips entries without valid emails' do
      allow(HTTP).to receive(:get).and_return(
        double(
          body: <<-HTML
            <html>
              <body>
                <div id="contentContactEmail"></div>
                <h1>Mairie d'Argenteuil</h1>
              </body>
            </html>
          HTML
        )
      )

      emails = get_townhall_emails(mock_urls)
      expect(emails).to be_empty
    end
  end
end
