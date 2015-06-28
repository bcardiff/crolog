require "./spec_helper"

describe Crolog do
  it "query" do
    Crolog.load

    rule male(:john)
    rule male(:andy)
    rule male(:carl)

    a = [] of String

    query male(y) do
      a << y.string
    end

    a.should eq(["john", "andy", "carl"])
  end
end
