require "../src/crolog"

Crolog.load "#{__DIR__}/sample.pl"

puts "joe's siblings"

# ?- sibling(jdoe, Y)
query sibling(:joe, y) do
  puts y
end
