require 'spec_helper'

describe Wptemplates do
  
  it "parses a template without any parameters" do
    parsed = subject.parse("{{foo}}")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("")
    expect(parsed[0].text).to eq("")
    expect(parsed.templates.length).to eq(1)
    expect(parsed[0].name).to eq(:foo)
  end
  
  it "parses a template with numeric parameters" do
    parsed = subject.parse("{{foo|a|b|c}}")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("")
    expect(parsed[0].text).to eq("")
    expect(parsed.templates.length).to eq(1)
    expect(parsed[0].name).to eq(:foo)
    p = parsed[0].params
    expect(p.keys).to eq([0,1,2])
    expect(p[0].length).to eq(1)
    expect(p[0].text).to eq("a")
    expect(p[0][0].text).to eq("a")
    expect(p[1].length).to eq(1)
    expect(p[1].text).to eq("b")
    expect(p[1][0].text).to eq("b")
    expect(p[2].length).to eq(1)
    expect(p[2].text).to eq("c")
    expect(p[2][0].text).to eq("c")
  end
  
  it "parses a template with named parameters" do
    parsed = subject.parse("{{foo| a = x |b = y \n|c= z z }}")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("")
    expect(parsed[0].text).to eq("")
    expect(parsed.templates.length).to eq(1)
    expect(parsed[0].name).to eq(:foo)
    p = parsed[0].params
    expect(p.keys).to eq([:a,:b,:c])
    expect(p[:a].length).to eq(1)
    expect(p[:a].text).to eq("x")
    expect(p[:a][0].text).to eq("x")
    expect(p[:b].length).to eq(1)
    expect(p[:b].text).to eq("y")
    expect(p[:b][0].text).to eq("y")
    expect(p[:c].length).to eq(1)
    expect(p[:c].text).to eq("z z")
    expect(p[:c][0].text).to eq("z z")
  end
  
  it "doesn't have problems with empty numeric parameters" do
    parsed = subject.parse("{{foo|}}")
    expect(parsed.length).to eq(1)
    p = parsed[0].params
    expect(p.keys).to eq([0])
    expect(p[0].length).to eq(1)
    expect(p[0].text).to eq("")
    expect(p[0][0].text).to eq("")
  end
  
  it "doesn't have problems with empty valued named parameters" do
    parsed = subject.parse("{{foo|b=}}")
    expect(parsed.length).to eq(1)
    p = parsed[0].params
    expect(p.keys).to eq([:b])
    expect(p[:b].length).to eq(1)
    expect(p[:b].text).to eq("")
    expect(p[:b][0].text).to eq("")
  end
  
  it "doesn't have problems with white spece only valued named parameters" do
    parsed = subject.parse("{{foo|c= }}")
    expect(parsed.length).to eq(1)
    p = parsed[0].params
    expect(p.keys).to eq([:c])
    expect(p[:c].length).to eq(1)
    expect(p[:c].text).to eq("")
    expect(p[:c][0].text).to eq("")
  end
  
  it "doesn't have problems with empty name parameters" do
    parsed = subject.parse("{{foo|=3}}")
    p = parsed[0].params
    expect(p[:""].length).to eq(1)
    expect(p[:""].text).to eq("3")
    expect(p[:""][0].text).to eq("3")
  end
  
  it "doesn't have problems with mixed empty stuff" do
    parsed = subject.parse("{{foo||b=|c= |=3}}")
    expect(parsed.length).to eq(1)
    p = parsed[0].params
    expect(p.keys).to eq([0,:b,:c,:""])
    expect(p[0].length).to eq(1)
    expect(p[0].text).to eq("")
    expect(p[0][0].text).to eq("")
    expect(p[:b].length).to eq(1)
    expect(p[:b].text).to eq("")
    expect(p[:b][0].text).to eq("")
    expect(p[:c].length).to eq(1)
    expect(p[:c].text).to eq("")
    expect(p[:c][0].text).to eq("")
    expect(p[:""].length).to eq(1)
    expect(p[:""].text).to eq("3")
    expect(p[:""][0].text).to eq("3")
  end
  
  it "parses nested templates" do
    parsed = subject.parse("{{foo| a = {{bar|j|k}} |b = y {{baz|p=q}} y2 \n|c= z z }}")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("")
    expect(parsed[0].text).to eq("")
    expect(parsed.templates.length).to eq(1)
    expect(parsed.all_templates.length).to eq(3)
    expect(parsed[0].name).to eq(:foo)
    p = parsed[0].params
    expect(p.keys).to eq([:a,:b,:c])
    expect(p[:a].templates.length).to eq(1)
    expect(p[:a].text).to eq("")
    expect(p[:a].templates[0].name).to eq(:bar)
    expect(p[:a].templates[0].params.keys).to eq([0,1])
    expect(p[:a].templates[0].params[0].text).to eq("j")
    expect(p[:a].templates[0].params[1].text).to eq("k")
    expect(p[:b].length).to eq(3)
    expect(p[:b].templates.length).to eq(1)
    expect(p[:b].text).to eq("y  y2")
    expect(p[:b][0].text).to eq("y ")
    expect(p[:b][2].text).to eq(" y2")
    expect(p[:b].templates[0].name).to eq(:baz)
    expect(p[:b].templates[0].params.keys).to eq([:p])
    expect(p[:b].templates[0].params[:p].text).to eq("q")
    expect(p[:c].length).to eq(1)
    expect(p[:c].text).to eq("z z")
    expect(p[:c][0].text).to eq("z z")
  end
  
  it "barkes about unclosed templates" do
    expect { subject.parse("{{foo") }.to raise_error
    expect { subject.parse("{{foo}}{{") }.to raise_error
  end
  
  it "does not bark when {{ is in the name though" do
    expect(subject.parse("{{{{foo}}")[0].name).to eq(:"{{foo")
  end
  
  it "finds nested templates" do
    parsed = subject.parse("{{foo| a = {{bar|j|k}} |b = y {{foo|p=q}} y2 \n|c= z z }}")
    expect(parsed.template_of :foo).to eq(parsed.templates[0])
    expect(parsed.templates_of :foo).to eq([parsed.templates[0]])
    expect(parsed.deep_template_of :foo).to eq(parsed.templates[0])
    expect(parsed.all_templates_of :foo).to eq([parsed.templates[0], parsed.templates[0].params[:b].templates[0]])
    expect(parsed.template_of :bar).to be_nil
    expect(parsed.templates_of :bar).to eq([])
    expect(parsed.deep_template_of :bar).to eq(parsed.templates[0].params[:a].templates[0])
    expect(parsed.all_templates_of :bar).to eq([parsed.templates[0].params[:a].templates[0]])
  end
  
  it "optionally navigates to nested templates' parameter texts" do
    parsed = subject.parse("{{foo| a = {{bar|j|k}} |b = y {{foo|p=q}} y2 \n|c= z z }}")
    #expect(parsed.navigate(:foo)).to eq(parsed.templates(:foo))
    expect(parsed.navigate(:foo, :a, :bar, 0) {|p| p.text}).to eq("j")
    expect(parsed.navigate(:foo, :a, :bar, 1) {|p| p.text}).to eq("k")
    expect(parsed.navigate(:foo, :a, :bar, 2) {|p| p.text}).to be_nil
    expect(parsed.navigate(:foo, :a, :bar) {|t| t.params.keys}).to eq([0,1])
    expect(parsed.navigate(:foo, :a, :baz) {|t| t.params}).to be_nil
    expect(parsed.navigate(:foo, :a, :baz, 2) {|p| p.text}).to be_nil
    expect(parsed.navigate(:foo, :b, :foo, :p) {|p| p.text}).to eq("q")
    expect(parsed.navigate(:foo, :b, :foo, :r) {|p| p.text}).to be_nil
  end
  
end