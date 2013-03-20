require 'spec_helper'

describe Wptemplates::Utils do
  
  describe '.symbolize' do
    it "symbolizes strings" do
      expect(subject.symbolize(" foo ")).to eq(:foo)
      expect(subject.symbolize("_foo_")).to eq(:_foo_)
      expect(subject.symbolize("foo")).to eq(:foo)
      expect(subject.symbolize("FOO")).to eq(:foo)
      expect(subject.symbolize("FoO")).to eq(:foo)
      expect(subject.symbolize("foo bar")).to eq(:foo_bar)
      expect(subject.symbolize("Foo BAR")).to eq(:foo_bar)
      expect(subject.symbolize("foo_bar")).to eq(:foo_bar)
      expect(subject.symbolize("foo__bar")).to eq(:foo__bar)
      expect(subject.symbolize("fooBar")).to eq(:foobar)
    end
  end
  
end