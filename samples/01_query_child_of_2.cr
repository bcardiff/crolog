require "../src/crolog"

Crolog.load "#{__DIR__}/sample.pl"

puts "steve's childs"

# ?- child_of(steve, Y)
query child_of(:steve, y) do
  puts y
end
