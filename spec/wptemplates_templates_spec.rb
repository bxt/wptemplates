require 'spec_helper'

describe Wptemplates do
  
  it "parses a template without any parameters" do
    parsed = Wptemplates.parse("{{foo}}")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("")
    expect(parsed[0].text).to eq("")
    expect(parsed.templates.length).to eq(1)
    expect(parsed[0].name).to eq(:foo)
  end
  
  it "parses a template with numeric parameters" do
    parsed = Wptemplates.parse("{{foo|a|b|c}}")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("")
    expect(parsed[0].text).to eq("")
    expect(parsed.templates.length).to eq(1)
    expect(parsed[0].name).to eq(:foo)
    expect(parsed[0].params.keys).to eq([0,1,2])
    expect(parsed[0].params[0].length).to eq(1)
    expect(parsed[0].params[0].text).to eq("a")
    expect(parsed[0].params[0][0].text).to eq("a")
    expect(parsed[0].params[1].length).to eq(1)
    expect(parsed[0].params[1].text).to eq("b")
    expect(parsed[0].params[1][0].text).to eq("b")
    expect(parsed[0].params[2].length).to eq(1)
    expect(parsed[0].params[2].text).to eq("c")
    expect(parsed[0].params[2][0].text).to eq("c")
  end
  
  it "parses a template with named parameters" do
    parsed = Wptemplates.parse("{{foo| a = x |b = y \n|c= z z }}")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("")
    expect(parsed[0].text).to eq("")
    expect(parsed.templates.length).to eq(1)
    expect(parsed[0].name).to eq(:foo)
    expect(parsed[0].params.keys).to eq([:a,:b,:c])
    expect(parsed[0].params[:a].length).to eq(1)
    expect(parsed[0].params[:a].text).to eq("x")
    expect(parsed[0].params[:a][0].text).to eq("x")
    expect(parsed[0].params[:b].length).to eq(1)
    expect(parsed[0].params[:b].text).to eq("y")
    expect(parsed[0].params[:b][0].text).to eq("y")
    expect(parsed[0].params[:c].length).to eq(1)
    expect(parsed[0].params[:c].text).to eq("z z")
    expect(parsed[0].params[:c][0].text).to eq("z z")
  end
  
  it "doesn't have problems with empty numeric parameters" do
    parsed = Wptemplates.parse("{{foo|}}")
    expect(parsed.length).to eq(1)
    expect(parsed[0].params.keys).to eq([0])
    expect(parsed[0].params[0].length).to eq(1)
    expect(parsed[0].params[0].text).to eq("")
    expect(parsed[0].params[0][0].text).to eq("")
  end
  
  it "doesn't have problems with empty valued named parameters" do
    parsed = Wptemplates.parse("{{foo|b=}}")
    expect(parsed.length).to eq(1)
    expect(parsed[0].params.keys).to eq([:b])
    expect(parsed[0].params[:b].length).to eq(1)
    expect(parsed[0].params[:b].text).to eq("")
    expect(parsed[0].params[:b][0].text).to eq("")
  end
  
  it "doesn't have problems with white spece only valued named parameters" do
    parsed = Wptemplates.parse("{{foo|c= }}")
    expect(parsed.length).to eq(1)
    expect(parsed[0].params.keys).to eq([:c])
    expect(parsed[0].params[:c].length).to eq(1)
    expect(parsed[0].params[:c].text).to eq("")
    expect(parsed[0].params[:c][0].text).to eq("")
  end
  
  it "doesn't have problems with empty name parameters" do
    parsed = Wptemplates.parse("{{foo|=3}}")
    expect(parsed[0].params[:""].length).to eq(1)
    expect(parsed[0].params[:""].text).to eq("3")
    expect(parsed[0].params[:""][0].text).to eq("3")
  end
  
  it "doesn't have problems with mixed empty stuff" do
    parsed = Wptemplates.parse("{{foo||b=|c= |=3}}")
    expect(parsed.length).to eq(1)
    expect(parsed[0].params.keys).to eq([0,:b,:c,:""])
    expect(parsed[0].params[0].length).to eq(1)
    expect(parsed[0].params[0].text).to eq("")
    expect(parsed[0].params[0][0].text).to eq("")
    expect(parsed[0].params[:b].length).to eq(1)
    expect(parsed[0].params[:b].text).to eq("")
    expect(parsed[0].params[:b][0].text).to eq("")
    expect(parsed[0].params[:c].length).to eq(1)
    expect(parsed[0].params[:c].text).to eq("")
    expect(parsed[0].params[:c][0].text).to eq("")
    expect(parsed[0].params[:""].length).to eq(1)
    expect(parsed[0].params[:""].text).to eq("3")
    expect(parsed[0].params[:""][0].text).to eq("3")
  end
  
  it "parses nested templates" do
    parsed = Wptemplates.parse("{{foo| a = {{bar|j|k}} |b = y {{baz|p=q}} y2 \n|c= z z }}")
    expect(parsed.length).to eq(1)
    expect(parsed.text).to eq("")
    expect(parsed[0].text).to eq("")
    expect(parsed.templates.length).to eq(1)
    expect(parsed.all_templates.length).to eq(3)
    expect(parsed[0].name).to eq(:foo)
    expect(parsed[0].params.keys).to eq([:a,:b,:c])
    expect(parsed[0].params[:a].templates.length).to eq(1)
    expect(parsed[0].params[:a].text).to eq("")
    expect(parsed[0].params[:a].templates[0].name).to eq(:bar)
    expect(parsed[0].params[:a].templates[0].params.keys).to eq([0,1])
    expect(parsed[0].params[:a].templates[0].params[0].text).to eq("j")
    expect(parsed[0].params[:a].templates[0].params[1].text).to eq("k")
    expect(parsed[0].params[:b].length).to eq(3)
    expect(parsed[0].params[:b].templates.length).to eq(1)
    expect(parsed[0].params[:b].text).to eq("y  y2")
    expect(parsed[0].params[:b][0].text).to eq("y ")
    expect(parsed[0].params[:b][2].text).to eq(" y2")
    expect(parsed[0].params[:b].templates[0].name).to eq(:baz)
    expect(parsed[0].params[:b].templates[0].params.keys).to eq([:p])
    expect(parsed[0].params[:b].templates[0].params[:p].text).to eq("q")
    expect(parsed[0].params[:c].length).to eq(1)
    expect(parsed[0].params[:c].text).to eq("z z")
    expect(parsed[0].params[:c][0].text).to eq("z z")
  end
  
  it "barkes about unclosed templates" do
    expect { Wptemplates.parse("{{foo") }.to raise_error
    expect { Wptemplates.parse("{{foo}}{{") }.to raise_error
  end
  
  it "does not bark when {{ is in the name though" do
    expect(Wptemplates.parse("{{{{foo}}")[0].name).to eq(:"{{foo")
  end
  
  it "finds nested templates" do
    parsed = Wptemplates.parse("{{foo| a = {{bar|j|k}} |b = y {{foo|p=q}} y2 \n|c= z z }}")
    expect(parsed.templates_of :foo).to eq([parsed.templates[0]])
    expect(parsed.all_templates_of :foo).to eq([parsed.templates[0], parsed.templates[0].params[:b].templates[0]])
    expect(parsed.templates_of :bar).to eq([])
    expect(parsed.all_templates_of :bar).to eq([parsed.templates[0].params[:a].templates[0]])
  end
  
end