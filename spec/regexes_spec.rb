require 'spec_helper'
require 'strscan'

def ScanShortcutFor(regex)
  Module.new do
    define_method :scan do |text|
      StringScanner.new(text).scan(Wptemplates::Regexes.send(regex))
    end
    define_method :scanner_after do |text|
      s = StringScanner.new(text)
      s.scan(Wptemplates::Regexes.send(regex))
      s
    end
  end
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
  
  describe '.from_pipe_till_equals_no_doubleclosebrace_or_pipe' do
    include ScanShortcutFor(:from_pipe_till_equals_no_doubleclosebrace_or_pipe)
    
    context 'when there is an equals sign and a pipe' do
      it 'consumes a string including equals with no doubleclosebraces or pipes at all' do
        expect(scan "|abc=").to eq("|abc=")
        expect(scan "|abc=d").to eq("|abc=")
        expect(scan "|ab{{c=d").to eq("|ab{{c=")
      end
      it 'fails when doubleclosebraces occur before equals' do
        expect(scan "|abc}}d=e").to be_false
        expect(scan "|a{{bc}}d=e").to be_false
      end
      it 'ignores single closebraces' do
        expect(scan "|abc}d=e").to eq("|abc}d=")
        expect(scan "|a{{bc}d=e").to eq("|a{{bc}d=")
      end
      it 'fails when a pipe occurs before equals' do
        expect(scan "|abc|d=e").to be_false
        expect(scan "|a{{bc|d=e").to be_false
      end
      it 'does actually accept an empty string (epsilon transition)' do
        expect(scan "|=d").to eq("|=")
        expect(scan "|=").to eq("|=")
      end
      it 'consumes until equals even if other equals show up (not greedy)' do
        expect(scan "|ab=d=e").to eq("|ab=")
      end
      it 'provides us with the stuff between pipe and equals in the first index' do
        expect(scanner_after("|ab=c")[1]).to eq("ab")
        expect(scanner_after("|=c")[1]).to eq("")
      end
    end
    
    context 'when there is no equals sign' do
      it 'fails on plain string' do
        expect(scan "|abc").to be_false
      end
      it 'fails when there is a pipe' do
        expect(scan "abc|d").to be_false
        expect(scan "abcd|").to be_false
        expect(scan "|abcd").to be_false
      end
      it 'fails when there are doubleclosebraces' do
        expect(scan "abc}}d").to be_false
        expect(scan "abcd}}").to be_false
        expect(scan "}}abcd").to be_false
      end
    end
    context 'when the pipe is not a the beginning or there is no pipe' do
      it 'fails' do
        expect(scan "abc").to be_false
        expect(scan "abc=").to be_false
        expect(scan "a|bc=d").to be_false
        expect(scan " |bc=d").to be_false
      end
    end
    
  end
  
  describe '.a_pipe' do
    
  end
  
  describe '.a_doubleopenbrace' do
    
  end
  
  describe '.a_doubleclosingbrace' do
    
  end
  
end