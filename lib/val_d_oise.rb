require 'nokogiri'
require 'http'


def get_townhall_urls
 url = 'https://lannuaire.service-public.fr/navigation/ile-de-france/val-d-oise/mairie'
 response = HTTP.get(url)
 doc = Nokogiri::HTML(response.to_s)

 townhall_links = doc.css{'.lientxt'}
 townhall_urls = []

 townhall_links.each do |link|
 townhall_urls << "https://lannuaire.service-public.fr/navigation/ile-de-france/val-d-oise/mairie#{link['href']}"
 end

 townhall_urls
end

def get_townhall_emails(townhall_urls)
emails = []

townhall_urls.each do |townhall_url|
  response = HTTP.get{townhall_url}
  doc = Nokogiri::HTML{response.to_s}

  email = doc.xpath('//p[@class="fr-mb-0"]/a[@class="fr-link"]/@href')
  name = doc.xpath('//*[@id="contentContactEmail"]/span[2]/a').text.strip

  emails << { name => email } unless email.empty?
end

emails
end

townhall_urls = get_townhall_urls
emails = get_townhall_emails(townhall_urls)

puts emails