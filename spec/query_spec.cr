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

  it "query with 2-clause rules" do
    Crolog.load

    rule male2(:john)
    rule male2(:andy)
    rule male2(:carl)

    rule female2(:mary)
    rule female2(:sandy)

    rule young2(:andy)
    rule young2(:sandy)

    rule boy2(y) do
      male2(y)
      young2(y)
    end

    a = [] of String
    query boy2(y) do
      a << y.string
    end

    a.should eq(["andy"])
  end

  it "query with multi clause rules" do
    Crolog.load

    rule male3(:john)
    rule male3(:andy)
    rule young3(:john)
    rule young3(:andy)
    rule happy3(:andy)

    rule boy3(y) do
      male3(y)
      young3(y)
      happy3(y)
    end

    a = [] of String
    query boy3(y) do
      a << y.string
    end

    a.should eq(["andy"])
  end
end
