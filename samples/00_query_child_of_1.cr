require "../src/crolog"

Crolog.load "#{__DIR__}/sample.pl"

puts "joe's parents"

# ?- child_of(X, jdoe)
query child_of(x, :joe) do
  puts x
end
