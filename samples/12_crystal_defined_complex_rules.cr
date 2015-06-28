require "../src/crolog"

Crolog.load # without context

puts "crystal defined rules"

rule male(:john)
rule male(:andy)
rule male(:carl)

rule female(:mary)
rule female(:sandy)

rule young(:andy)
rule young(:sandy)

rule boy(y) do
  male(y)
  young(y)
end

query boy(x) do
  puts "#{x} is a boy"
end
