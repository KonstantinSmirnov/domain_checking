require 'whois-parser'
require 'translit'


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
      open('available_domains_ru.txt', 'a') do |f|
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

open('russian_dic.txt', 'r') do |poem|
  poem.each_line do |line|
    unless line == "\n"
      phrase = Translit.convert(line).gsub(/[\t]/, ' ').gsub(/[^a-zA-Z ]/, '').split(' ')
      phrase.each { |word| words << word if word.length <= max_letters_in_word }
    end
  end
end

threads = []

# TOO SLOW (1-thread)
#words.uniq.each { |w| check_domain("#{w}.ru") }

# OUT OF RESOURCES (1 thread = 1 check)
#for word in words.uniq
#  threads << Thread.new(word) do |word_to_check|
#    check_domain("#{ word_to_check }.ru")
#  end
#end

# OPTIMAL MULTITHREAD (1 thread = 1000 checks)
words.uniq.each_slice(1000) do |array|
  threads << Thread.new(array) do |array_check|
    array_check.each { |word| check_domain("#{word}.ru") }
  end
end

threads.each { |thr| thr.join }

puts "===CHECKED ALL WORDS!==="
