class TitleScraper
  include Sneakers::Worker
  from_queue 'downloads'

  def work(msg)
    doc = Nokogiri::HTML(open(msg))
    worker_trace "FOUND <#{doc.css('title').text}>"
    ack!
  end
end