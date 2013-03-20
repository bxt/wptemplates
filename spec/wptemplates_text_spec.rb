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
  
end