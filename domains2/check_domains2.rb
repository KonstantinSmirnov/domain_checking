require 'whois-parser'

@requests_counter = 0

def check_domain(domain)
  puts "Checking #{domain}"

  begin
    retries ||= 0
    
    record = Whois.whois(domain)
    parser = record.parser
    @requests_counter += 1
    if parser.registered?
      puts "Request #{@requests_counter}: #{domain} is registered!"
    else
      puts "Request #{@requests_counter}: #{domain} is AVAILABLE!"
      open('available_domains2.txt', 'a') do |f|
        f << "#{domain}\n"
      end
    end
  rescue
    puts "----------------------------"
    puts "=== Request #{@requests_counter}: PARSER ERROR!"
    puts "----------------------------"
    retry if (retries += 1) < 100
  end
end

words = []

a = ('a'..'z').to_a + ('0'..'9').to_a
min = 3
max = 4

(min..max).flat_map do |size| 
  a.repeated_permutation(size).each do |combination|
    words << combination.join('')
  end
end

#puts "TOTAL: #{words.count}"
#words.each { |w| puts "!!!!! #{ w }" }

#words.uniq.each { |w| check_domain("#{w}.com") }

threads = []

words.uniq.each_slice(words.count / 200) do |array|
  threads << Thread.new(array) do |array_check|
    array_check.each { |word| check_domain("#{word}.com") }
    #array_check.each { |word| puts "!!!! #{word}" }
  end
end

threads.each { |thr| thr.join }

puts "===CHECKED ALL #{words.count} WORDS!==="
