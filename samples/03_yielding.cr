require "../src/crolog"

Crolog.load "#{__DIR__}/sample.pl"


def humans
  query human(x) do
    yield x
  end
end

humans do |h|
  puts h
end
