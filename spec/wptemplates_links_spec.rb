require 'spec_helper'

describe Wptemplates do
  
  it "parses a basic link without any additions" do
    parsed = subject.parse("[[foo]]")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("foo")
    expect(parsed.links).to eq([parsed[0]])
    expect(parsed.all_links).to eq([parsed[0]])
    expect(parsed[0].text).to eq("foo")
    expect(parsed[0].link).to eq("Foo")
    expect(parsed[0].links).to eq([parsed[0]])
    expect(parsed[0].all_links).to eq([parsed[0]])
    expect(parsed[0].anchor).to be_nil
  end
  
  it "parses a basic link with anchor" do
    parsed = subject.parse("[[foo#bar]]")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("foo#bar")
    expect(parsed.links.length).to eq(1)
    expect(parsed[0].text).to eq("foo#bar")
    expect(parsed[0].link).to eq("Foo")
    expect(parsed[0].anchor).to eq("bar")
  end
  
  it "parses a link with postfix chars" do
    parsed = subject.parse("[[foo]]nx")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("foonx")
    expect(parsed.links.length).to eq(1)
    expect(parsed[0].text).to eq("foonx")
    expect(parsed[0].link).to eq("Foo")
  end
  
  it "parses a link with a pipe" do
    parsed = subject.parse("[[foo|bar]]")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("bar")
    expect(parsed.links.length).to eq(1)
    expect(parsed[0].text).to eq("bar")
    expect(parsed[0].link).to eq("Foo")
  end
  
  it "parses a link with pipe and postfix chars" do
    parsed = subject.parse("[[foo|bar]]ny")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("barny")
    expect(parsed.links.length).to eq(1)
    expect(parsed[0].text).to eq("barny")
    expect(parsed[0].link).to eq("Foo")
  end
  
  it "parses a link with a pipe" do
    parsed = subject.parse("[[foo|bar]]")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("bar")
    expect(parsed.links.length).to eq(1)
    expect(parsed[0].text).to eq("bar")
    expect(parsed[0].link).to eq("Foo")
  end
  
  it "parses a link with pipe trick for comma" do
    parsed = subject.parse("[[Boston, Massachusetts|]]")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("Boston")
    expect(parsed.links.length).to eq(1)
    expect(parsed[0].text).to eq("Boston")
    expect(parsed[0].link).to eq("Boston, Massachusetts")
  end
  
  it "parses a link with pipe trick for parens" do
    parsed = subject.parse("[[Pipe (computing)|]]")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("Pipe")
    expect(parsed.links.length).to eq(1)
    expect(parsed[0].text).to eq("Pipe")
    expect(parsed[0].link).to eq("Pipe (computing)")
  end
  
  it "parses a link with pipe trick for parens and comma" do
    parsed = subject.parse("[[Yours, Mine and Ours (1968 film)|]]")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("Yours, Mine and Ours")
    expect(parsed.links.length).to eq(1)
    expect(parsed[0].text).to eq("Yours, Mine and Ours")
    expect(parsed[0].link).to eq("Yours, Mine and Ours (1968 film)")
  end
  
  it "parses a link with pipe trick for multiple commas" do
    parsed = subject.parse("[[Il Buono, il Brutto, il Cattivo|]]")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("Il Buono")
    expect(parsed.links.length).to eq(1)
    expect(parsed[0].text).to eq("Il Buono")
    expect(parsed[0].link).to eq("Il Buono, il Brutto, il Cattivo")
  end
  
  it "parses a link without pipe trick when no space after comma" do
    parsed = subject.parse("[[a,b|]]")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("a,b")
    expect(parsed.links.length).to eq(1)
    expect(parsed[0].text).to eq("a,b")
    expect(parsed[0].link).to eq("A,b")
  end
  
  it "parses a link without pipe trick when parens are not matched" do
    parsed = subject.parse("[[a(b|]]")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("a(b")
    expect(parsed.links.length).to eq(1)
    expect(parsed[0].text).to eq("a(b")
    expect(parsed[0].link).to eq("A(b")
  end
  
  it "parses a link without pipe trick when there is something after parens" do
    parsed = subject.parse("[[a (b) c|]]")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("a (b) c")
    expect(parsed.links.length).to eq(1)
    expect(parsed[0].text).to eq("a (b) c")
    expect(parsed[0].link).to eq("A (b) c")
  end
  
  it "parses a link with pipe trick when there is something after parens but there are commas" do
    parsed = subject.parse("[[a(b), c|]]")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("a")
    expect(parsed.links.length).to eq(1)
    expect(parsed[0].text).to eq("a")
    expect(parsed[0].link).to eq("A(b), c")
  end
  
  it "parses a link with pipe trick when where is something other than comma after parens an then more commas" do
    parsed = subject.parse("[[a(b)x, c|]]")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("a(b)x")
    expect(parsed.links.length).to eq(1)
    expect(parsed[0].text).to eq("a(b)x")
    expect(parsed[0].link).to eq("A(b)x, c")
  end
  
  it "parses a link with pipe trick when where is something after parens but there are commas before" do
    parsed = subject.parse("[[a, (b)c|]]")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("a")
    expect(parsed.links.length).to eq(1)
    expect(parsed[0].text).to eq("a")
    expect(parsed[0].link).to eq("A, (b)c")
  end
  
  it "parses appends the lettes to a link with pipe trick (comma)" do
    parsed = subject.parse("[[a , c|]]n")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("a n")
    expect(parsed.links.length).to eq(1)
    expect(parsed[0].text).to eq("a n")
    expect(parsed[0].link).to eq("A , c")
  end
  
  it "parses appends the lettes to a link with pipe trick (parens)" do
    parsed = subject.parse("[[a (2014)|]]n")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("an")
    expect(parsed.links.length).to eq(1)
    expect(parsed[0].text).to eq("an")
    expect(parsed[0].link).to eq("A (2014)")
  end
  
  it "normalizes whitespace in link text" do
    parsed = subject.parse("[[ a  b __ c .  d  ]]")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("a b __ c . d")
    expect(parsed.links.length).to eq(1)
    expect(parsed[0].text).to eq("a b __ c . d")
    expect(parsed[0].link).to eq("A b c . d")
  end
  
  it "ignores unclosed links" do
    parsed = subject.parse("[[a")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("[[a")
    expect(parsed.links.length).to eq(0)
  end
  
  it "ignores unclosed links up to a newline" do
    parsed = subject.parse("[[a\nb]]")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("[[a\nb]]")
    expect(parsed.links.length).to eq(0)
  end
  
  it "matches ending brackets non-greedy" do
    parsed = subject.parse("[[a]]b]]c")
    expect(parsed.length).to eq(2)
    expect(parsed.text).to eq("ab]]c")
    expect(parsed.links.length).to eq(1)
    expect(parsed[0].text).to eq("ab")
    expect(parsed[0].link).to eq("A")
  end
  
  it "continures the pipe trick stripping a lot" do
    parsed = subject.parse("[[x(d), (d), (d), d(b), c|]]")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("x")
    expect(parsed.links.length).to eq(1)
    expect(parsed[0].text).to eq("x")
    expect(parsed[0].link).to eq("X(d), (d), (d), d(b), c")
  end
  
  it "may contain pipes in the description" do
    parsed = subject.parse("[[a|b|c]]d")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("b|cd")
    expect(parsed.links.length).to eq(1)
    expect(parsed[0].text).to eq("b|cd")
    expect(parsed[0].link).to eq("A")
  end
  
end