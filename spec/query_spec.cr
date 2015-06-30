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

  it "should query multi vars facts" do
    Crolog.load

    rule related(:foo, :bar)

    a = [] of {String,String}
    query related(x, y) do
      a << {x.string, y.string}
    end

    a.should eq([{"foo", "bar"}])
  end


  it "should define rule multi vars rules" do
    Crolog.load

    rule fact2(:foo, :bar)

    rule related2(x, y) do
      fact2(y, x)
    end

    a = [] of {String,String}
    query related2(j, k) do
      a << {j.string, k.string}
    end

    a.should eq([{"bar", "foo"}])
  end

  it "should return ints" do
    Crolog.load

    a = [] of Int32
    query between(1,4,x as Int32) do
      a << x
    end

    a.should eq([1,2,3,4])
  end

  it "should yield ints" do
    Crolog.load

    rule between2(0, y) do
      between(1,2,y)
    end

    a = [] of {Int32,Int32}
    query between2(x as Int32, y as Int32) do
      a << {x,y}
    end

    a.should eq([{0,1},{0,2}])
  end
end
