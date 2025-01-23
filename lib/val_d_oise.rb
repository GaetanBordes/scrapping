require 'mechanize'
require 'nokogiri'

class TownhallScraper
  BASE_URL = "https://lannuaire.service-public.fr"
  VAL_DOISE_PAGES = (1..7).map { |i| "#{BASE_URL}/navigation/ile-de-france/val-d-oise/mairie?page=#{i}" }

  def self.fetch_townhall_links(page)
    townhall_list = []
    page_links = page.search('//*[@id="main"]/div/div/div/article/div[3]/ul/li/div/div/p/a')

    if page_links.any?
      page_links.each do |link|
        townhall_list << { name: link.text.strip, url: link['href'] }
      end
    else
      puts "Aucun lien trouvé sur cette page."
    end

    townhall_list
  end
  def self.extract_email_from_townhall(townhall)
    agent = Mechanize.new
    townhall_page = agent.get(townhall[:url])
    email_element = townhall_page.at('//*[@id="contentContactEmail"]/span[2]/a')

    if email_element
      email = email_element.text.strip
      puts "Mairie: #{townhall[:name]} - Email: #{email}"
      { name: townhall[:name], email: email }
    else
      puts "Aucun email trouvé pour la mairie de #{townhall[:name]}."
      { name: townhall[:name], email: nil }
    end
  end
  def self.collect_townhall_emails
    agent = Mechanize.new
    all_emails = []

    VAL_DOISE_PAGES.each do |url|
      puts "Traitement de l'URL: #{url}"
      page = agent.get(url)
      townhalls = fetch_townhall_links(page)

      townhalls.each do |townhall|
        email_info = extract_email_from_townhall(townhall)
        all_emails << email_info if email_info[:email]
      end
    end

    all_emails
  end
end
emails = TownhallScraper.collect_townhall_emails