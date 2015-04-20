require 'active_support/all'

class Anki
  def transfer_900_line(line)
    line.gsub!("．",".")
    md = line.match(/(\d+\.?)\s*([a-zA-Z0-9!',\-\.\?。\s]+)/)
    number = md[1].strip
    english = md[2].strip
    chinese = md.post_match.strip
    return [number, english, chinese]
  end

  def transfer_900_all
    lines = File.readlines("data/900-english-sentence.txt")
    # lines = lines[0..100]
    File.open("data/900-english-sentence-t.txt","w") do |file|
      lines.map do |line|
        next if line.blank?
        r = self.transfer_900_line(line).join("|")
        file.puts r
        puts "#{r}\t\t\t#{line}"
      end
    end
  end
end
if __FILE__ == $0
  Anki.new.transfer_900_all
end


