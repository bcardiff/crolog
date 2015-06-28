require "../src/crolog"

Crolog.load # without context

puts "crystal defined facts"

rule male(:john)
rule male(:andy)
rule male(:carl)

query male(m) do
  puts m
end
