require 'spec_helper'

describe Wptemplates::Utils do
  
  describe '.normalize_link' do
    it 'removes spare spaces and underscores ' do
      expect(subject.normalize_link(" Jimbo_ __ Wales__")).to eq("Jimbo Wales")
    end
    it 'removes spare spaces and underscores around namespace nekudotayim' do
      pending "not sure if to implement here" do
        expect(subject.normalize_link("_User_: Jimbo_ __ Wales__")).to eq("User:Jimbo Wales")
      end
    end
    it 'capitalizes the first letter' do
      expect(subject.normalize_link("foo")).to eq("Foo")
    end
    it 'preserves case of the other letters' do
      expect(subject.normalize_link("fOo")).to eq("FOo")
    end
    it 'normalizes case of namespace prefix' do
      pending "not sure if to implement here" do
        expect(subject.normalize_link("fOoO:Bar")).to eq("Fooo:Bar")
      end
    end
  end
  
  describe '.symbolize' do
    it "symbolizes strings" do
      expect(subject.symbolize(" foo ")).to eq(:foo)
      expect(subject.symbolize("_foo_")).to eq(:foo)
      expect(subject.symbolize("foo")).to eq(:foo)
      expect(subject.symbolize("FOO")).to eq(:foo)
      expect(subject.symbolize("FoO")).to eq(:foo)
      expect(subject.symbolize("foo bar")).to eq(:foo_bar)
      expect(subject.symbolize("Foo BAR")).to eq(:foo_bar)
      expect(subject.symbolize("foo_bar")).to eq(:foo_bar)
      expect(subject.symbolize("foo__bar")).to eq(:foo_bar)
      expect(subject.symbolize("fooBar")).to eq(:foobar)
    end
  end
  
end