require 'whois-parser'


def check_domain(domain)
  puts "Checking #{domain}"

  begin
    retries ||= 0
    
    record = Whois.whois(domain)
    parser = record.parser
    
    if parser.registered?
      puts "#{domain} is registered!"
    else
      puts "#{domain} is AVAILABLE!"
      open('available_domains.txt', 'a') do |f|
        f << "#{domain}\n"
      end
    end
  rescue
    puts "----------------------------"
    puts "======= PARSER ERROR ======="
    puts "----------------------------"
    retry if (retries += 1) < 100
  end
end

words = []
max_letters_in_word = 8

open('input_data.txt', 'r') do |poem|
  poem.each_line do |line|
    unless line == "\n"
      phrase = line.gsub(/[\t]/, ' ').gsub(/[^a-zA-Z ]/, '').split(' ')
      phrase.each { |word| words << word if word.length <= max_letters_in_word }
    end
  end
end

#words.uniq.each { |w| check_domain("#{w}.com") }

threads = []

words.uniq.each_slice(1000) do |array|
  threads << Thread.new(array) do |array_check|
    array_check.each { |word| check_domain("#{word}.com") }
  end
end

threads.each { |thr| thr.join }

puts "===CHECKED ALL WORDS!==="
