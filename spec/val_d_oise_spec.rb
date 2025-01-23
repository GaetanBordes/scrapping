require 'mechanize'
require 'nokogiri'
require_relative '../lib/val_d_oise'

RSpec.describe TownhallScraper do
  let(:base_url) { "https://lannuaire.service-public.fr" }
  let(:sample_page) { instance_double(Mechanize::Page) }
  let(:agent) { instance_double(Mechanize) }
  let(:sample_townhall) { { name: "Sample Townhall", url: "#{base_url}/sample-townhall" } }
  let(:sample_email) { "contact@sample-townhall.fr" }

  before do
    allow(Mechanize).to receive(:new).and_return(agent)
  end

  describe '.fetch_townhall_links' do
    it 'returns a list of townhall links from the page' do
      html_links = [
        double('link', text: "Townhall A", '[]': "#{base_url}/townhall-a"),
        double('link', text: "Townhall B", '[]': "#{base_url}/townhall-b")
      ]

      allow(sample_page).to receive(:search).with('//*[@id="main"]/div/div/div/article/div[3]/ul/li/div/div/p/a')
                                           .and_return(html_links)

      result = TownhallScraper.fetch_townhall_links(sample_page)
      expect(result).to eq([
        { name: "Townhall A", url: "#{base_url}/townhall-a" },
        { name: "Townhall B", url: "#{base_url}/townhall-b" }
      ])
    end

    it 'logs a message when no links are found' do
      allow(sample_page).to receive(:search).and_return([])

      expect { TownhallScraper.fetch_townhall_links(sample_page) }.to output(/Aucun lien trouvé/).to_stdout
    end
  end

  describe '.extract_email_from_townhall' do
    it 'returns the email of a townhall when present' do
      townhall_page = instance_double(Mechanize::Page)
      email_element = double('email_element', text: sample_email)

      allow(agent).to receive(:get).with(sample_townhall[:url]).and_return(townhall_page)
      allow(townhall_page).to receive(:at).with('//*[@id="contentContactEmail"]/span[2]/a').and_return(email_element)

      result = TownhallScraper.extract_email_from_townhall(sample_townhall)
      expect(result).to eq({ name: "Sample Townhall", email: sample_email })
    end

    it 'logs a message and returns nil when no email is found' do
      townhall_page = instance_double(Mechanize::Page)

      allow(agent).to receive(:get).with(sample_townhall[:url]).and_return(townhall_page)
      allow(townhall_page).to receive(:at).and_return(nil)

      expect { TownhallScraper.extract_email_from_townhall(sample_townhall) }.to output(/Aucun email trouvé/).to_stdout
      result = TownhallScraper.extract_email_from_townhall(sample_townhall)
      expect(result).to eq({ name: "Sample Townhall", email: nil })
    end
  end

  describe '.collect_townhall_emails' do
    it 'collects emails from multiple pages of townhalls' do
      pages = [
        instance_double(Mechanize::Page),
        instance_double(Mechanize::Page)
      ]

      allow(agent).to receive(:get).and_return(*pages)
      allow(TownhallScraper).to receive(:fetch_townhall_links)
                                .and_return([{ name: "Townhall A", url: "#{base_url}/townhall-a" }],
                                            [{ name: "Townhall B", url: "#{base_url}/townhall-b" }])
      allow(TownhallScraper).to receive(:extract_email_from_townhall)
                                .with(hash_including(name: "Townhall A"))
                                .and_return({ name: "Townhall A", email: "contact@townhall-a.fr" })
      allow(TownhallScraper).to receive(:extract_email_from_townhall)
                                .with(hash_including(name: "Townhall B"))
                                .and_return({ name: "Townhall B", email: "contact@townhall-b.fr" })

      result = TownhallScraper.collect_townhall_emails

      # Debugging outputs for verification of duplicates
      puts "Résultats avant suppression des doublons : #{result}"

      # Vérification du résultat final sans doublons
      expect(result).to match_array([
        { name: "Townhall A", email: "contact@townhall-a.fr" },
        { name: "Townhall B", email: "contact@townhall-b.fr" }
      ])
    end
  end
end
