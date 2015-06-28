require "../src/crolog"

Crolog.load # without context

puts "crystal defined rules"

rule male(:john)
rule male(:andy)
rule male(:carl)

rule female(:mary)
rule female(:sandy)

rule human(y) do
  male(y)
end

rule human(z) do
  female(z)
end

query human(x) do
  puts "#{x} is human"
end
