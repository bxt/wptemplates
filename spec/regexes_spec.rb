require 'spec_helper'
require 'strscan'

def ScanShortcutFor(regex)
  Module.new { define_method :scan do |text|
    StringScanner.new(text).scan(Wptemplates::Regexes.send(regex))
  end }
end

describe Wptemplates::Regexes do
  
  describe '.till_doublebrace_or_pipe' do
    include ScanShortcutFor(:till_doublebrace_or_pipe)
    
    it 'consumes a string with no doublebraces or pipes at all' do
      expect(scan "abc").to eq("abc")
    end
    it 'consumes until doublebraces or pipe' do
      expect(scan "abc{{d").to eq("abc")
      expect(scan "abc|d").to eq("abc")
      expect(scan "abc}}d").to eq("abc")
    end
    it 'does not accept an empty string (epsilon transition)' do
      expect(scan "{{d").to be_false
      expect(scan "|d").to be_false
      expect(scan "}}d").to be_false
    end
    it 'consumes until doublebraces or pipe even if other braces and pipes show up (not greedy)' do
      expect(scan "ab|c{{d}}e").to eq("ab")
      expect(scan "ab|c|d|e").to eq("ab")
      expect(scan "ab{{c|d}}e").to eq("ab")
      expect(scan "ab}}c|d{{e").to eq("ab")
    end
    it 'ignores lone braces' do
      expect(scan "ab{c|d}}e").to eq("ab{c")
      expect(scan "ab}c|d{{e").to eq("ab}c")
    end
  end
  
  describe '.till_doubleopenbrace' do
    include ScanShortcutFor(:till_doubleopenbrace)
    
    it 'consumes a string with no doubleopenbraces at all' do
      expect(scan "abc").to eq("abc")
      expect(scan "ab}}c").to eq("ab}}c")
      expect(scan "ab|c").to eq("ab|c")
    end
    it 'consumes until doubleopenbraces' do
      expect(scan "abc{{d").to eq("abc")
      expect(scan "abc|d{{").to eq("abc|d")
      expect(scan "abc}}d{{").to eq("abc}}d")
    end
    it 'does not accept an empty string (epsilon transition)' do
      expect(scan "{{d").to be_false
    end
    it 'consumes until doubleopenbraces even if other doubleopenbraces show up (not greedy)' do
      expect(scan "ab{{d{{e").to eq("ab")
    end
    it 'ignores lone braces' do
      expect(scan "ab{c{{e").to eq("ab{c")
    end
  end
  
  describe '.till_doubleclosebrace_or_pipe' do
    include ScanShortcutFor(:till_doubleclosebrace_or_pipe)
    
    it 'consumes a string with no doubleclosebraces or pipes at all' do
      expect(scan "abc").to eq("abc")
      expect(scan "ab{{c").to eq("ab{{c")
    end
    it 'consumes until doubleclosebraces' do
      expect(scan "abc}}d").to eq("abc")
      expect(scan "a{{bc}}d").to eq("a{{bc")
    end
    it 'consumes until a pipe' do
      expect(scan "abc|d").to eq("abc")
      expect(scan "a{{bc|d").to eq("a{{bc")
    end
    it 'does not accept an empty string (epsilon transition)' do
      expect(scan "}}d").to be_false
      expect(scan "|d").to be_false
    end
    it 'consumes until doubleclosebracees even if other doubleclosebrace show up (not greedy)' do
      expect(scan "ab}}d}}e").to eq("ab")
    end
    it 'consumes until a pipe even if other pipes show up (not greedy)' do
      expect(scan "ab|d|e").to eq("ab")
    end
    it 'ignores lone braces' do
      expect(scan "ab}c}}e").to eq("ab}c")
    end
  end
  
  describe '.an_equals_no_doubleclosebrace_or_pipe' do
    
  end
  
  describe '.a_pipe' do
    
  end
  
  describe '.a_doubleopenbrace' do
    
  end
  
  describe '.a_doubleclosingbrace' do
    
  end
  
end