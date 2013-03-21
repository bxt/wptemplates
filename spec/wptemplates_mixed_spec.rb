require 'spec_helper'

describe Wptemplates do
  
  it "parses link, text, template" do
    parsed = subject.parse("[[foo]] bar {{baz}}")
    expect(parsed.length).to eq(3)
    expect(parsed.text).to eq("foo bar ")
    expect(parsed.links.length).to eq(1)
    expect(parsed[0].text).to eq("foo")
    expect(parsed[0].link).to eq("Foo")
    expect(parsed[1].text).to eq(" bar ")
    expect(parsed[2].text).to eq("")
    expect(parsed[2].name).to eq(:baz)
  end
  
  it "parses template, text, link" do
    parsed = subject.parse("{{baz}} bar [[foo]]")
    expect(parsed.length).to eq(3)
    expect(parsed.text).to eq(" bar foo")
    expect(parsed.links.length).to eq(1)
    expect(parsed[0].text).to eq("")
    expect(parsed[0].name).to eq(:baz)
    expect(parsed[1].text).to eq(" bar ")
    expect(parsed[2].text).to eq("foo")
    expect(parsed[2].link).to eq("Foo")
  end
  
  it "parses a link in a template" do
    parsed = subject.parse("{{baz|[[foo]]}}")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("")
    expect(parsed.templates.length).to eq(1)
    expect(parsed[0].text).to eq("")
    expect(parsed[0].name).to eq(:baz)
    expect(parsed[0].params.keys).to eq([0])
    expect(parsed[0].params[0].length).to eq(1)
    expect(parsed[0].params[0].links.length).to eq(1)
    expect(parsed[0].params[0][0].text).to eq("foo")
    expect(parsed[0].params[0][0].link).to eq("Foo")
  end
  
  it "parses a link in a template with whitespace removed" do
    parsed = subject.parse("{{baz|p = [[foo]] }}")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("")
    expect(parsed.templates.length).to eq(1)
    expect(parsed[0].text).to eq("")
    expect(parsed[0].name).to eq(:baz)
    expect(parsed[0].params.keys).to eq([:p])
    expect(parsed[0].params[:p].text).to eq("foo")
    expect(parsed[0].params[:p].length).to eq(1)
    expect(parsed[0].params[:p].links.length).to eq(1)
    expect(parsed[0].params[:p][0].text).to eq("foo")
    expect(parsed[0].params[:p][0].link).to eq("Foo")
  end
  
  it "parses text, link, letters, link" do
    parsed = subject.parse("bar [[foo]]ny baz")
    expect(parsed.length).to eq(3)
    expect(parsed.text).to eq("bar foony baz")
    expect(parsed.links.length).to eq(1)
    expect(parsed[0].text).to eq("bar ")
    expect(parsed[1].text).to eq("foony")
    expect(parsed[1].link).to eq("Foo")
    expect(parsed[2].text).to eq(" baz")
  end
  
end