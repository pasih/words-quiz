#!/usr/bin/env ruby
#
# This is a ruby conversion of an old, old Perl script.
# It's not written for clarity and it is not a model of
# good coding style. I've used some Ruby features
# (e.g. Lambdas) for the sake of using them.
#
# The word file (default words.txt) should be in format:
# english<tab>finnish<tab>extra info

require 'optparse'

options = {
  :numwords => 8,
  :lang => nil
}

OptionParser.new do |opts|
  opts.banner = "Usage: lang.rb [options]"

  opts.on("-l l", "--language=l", "Word quiz language") do |lang|
    if ["english", "en", "e"].include?(lang.downcase)
      options[:lang] = :en
    elsif ["finnish", "fi", "f"].include?(lang.downcase)
      options[:lang] = :fi
    else
      puts "Unknown language, defaulting to English"
      options[:lang] = :en
    end
  end
  opts.on("-n n", "--num-words=n",  OptionParser::DecimalInteger, "How many words to try?") do |n|
    if n == 0
      puts "No words!"
      exit 
    end
    options[:numwords] = n
  end
end.parse!

filename = ARGV[0] == nil ? "words.txt" : ARGV[0]

begin
  words = File.open(filename, 'r');
rescue
  puts "Could not open file: " + filename
  exit
end

dict = Hash.new

words.each do |f|
  words = f.split
  dict[words.first] = {
    :translation => words[1],
    :info => words[2..-1].join(" ")
  }
end

words = Hash[dict.to_a.shuffle[0..options[:numwords]-1]]

uus =-> a { a.tr("_", " ") }
us =-> a { a.tr(" ", "_") }

goods = []
bads = []

order = -1
if options[:lang] == :en
  order = 0
elsif options[:lang] == :fi
  order = 1
end

words.each do |word|
  o = (order == -1) ? 0 + rand(2) : order
  case o
  when 0
    question = word[0]
    answer = uus[word[1][:translation]]
  when 1
    question = uus[word[1][:translation]]
    answer = word[0]
  end
  puts question + "?"
  guess = $stdin.gets.chomp
  if (guess == answer)
    goods.push word
  elsif
    bads.push word
  end
  puts "---"
end

def report(f)
  printf("%s: %s\n", f[0], f[1][:translation])
    puts "\textra: " + f[1][:info] if not f[1][:info].empty?
end

puts
if not goods.empty?
  puts "You got these right (#{goods.size} out of #{options[:numwords]}):" 
  goods.each { |f| report(f) }
  puts
end
if not bads.empty?
  puts "You got these wrong (#{bads.size} out of #{options[:numwords]}):"
  bads.each { |f| report(f) }
end
