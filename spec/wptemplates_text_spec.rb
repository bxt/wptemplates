require 'spec_helper'

describe Wptemplates do
  
  it "parses some text into a soup with a single text node" do
    parsed = subject.parse(" some text ")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq(" some text ")
    expect(parsed[0].text).to eq(" some text ")
    expect(parsed.templates).to eq([])
  end
  
  it "parses the empty string into a soup with a single empty text node" do
    parsed = subject.parse("")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("")
    expect(parsed[0].text).to eq("")
    expect(parsed.templates).to eq([])
  end
  
  it "removes normal html comments" do
    parsed = subject.parse("a<!-- b -->a")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("aa")
    expect(parsed[0].text).to eq("aa")
    expect(parsed.templates).to eq([])
    expect(parsed.links).to eq([])
  end
  
  it "removes html comments with excess minus" do
    parsed = subject.parse("a<!--- b -->a")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("aa")
    expect(parsed[0].text).to eq("aa")
    expect(parsed.templates).to eq([])
    expect(parsed.links).to eq([])
  end
  
  it "removes html comments with invalid combinations of <!-> in between" do
    parsed = subject.parse("d1<!-- d2 -><!-- d3 -- >d4<! -- > d6-->d6")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("d1d6")
    expect(parsed[0].text).to eq("d1d6")
    expect(parsed.templates).to eq([])
    expect(parsed.links).to eq([])
  end
  
  it "removes html comments which remove links closing tag" do
    parsed = subject.parse("[[a|<!-- ]] -->")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("[[a|")
    expect(parsed[0].text).to eq("[[a|")
    expect(parsed.templates).to eq([])
    expect(parsed.links).to eq([])
  end
  
  it "removes html comments which remove links opening tag" do
    parsed = subject.parse("<!-- [[a| -->]]")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("]]")
    expect(parsed[0].text).to eq("]]")
    expect(parsed.templates).to eq([])
    expect(parsed.links).to eq([])
  end
  
end