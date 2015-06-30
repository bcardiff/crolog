require "../src/crolog"

Crolog.load

puts "crystal defined predicates"

rule def mymod(a, b, c)
  c.unify(a.int % b.int)
end

query mymod(5, 3, x as Int32) do
  puts "#{x} was returned"
end
