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
    include ScanShortcutFor(:a_pipe)
    
    it 'consumes a pipe' do
      expect(scan "|").to eq("|")
      expect(scan "|a").to eq("|")
    end
    it 'consumes only one pipe even if there are others around (not greedy)' do
      expect(scan "|||").to eq("|")
      expect(scan "|a|").to eq("|")
      expect(scan "|a|a").to eq("|")
    end
    it 'fails when there is stuff before the pipe' do
      expect(scan "a|").to be_false
      expect(scan "a|b").to be_false
    end
  end
  
  describe '.a_doubleopenbrace' do
    include ScanShortcutFor(:a_doubleopenbrace)
    
    it 'consumes a doubleopenbrace' do
      expect(scan "{{").to eq("{{")
      expect(scan "{{a").to eq("{{")
    end
    it 'consumes only one doubleopenbrace even if there are others around (not greedy)' do
      expect(scan "{{a{{").to eq("{{")
     expect(scan "{{a{{a").to eq("{{")
    end
    it 'fails when there is stuff before the doubleopenbrace' do
      expect(scan "a{{").to be_false
      expect(scan "a{{b").to be_false
    end
    it 'ignores singleopenbrace' do
      expect(scan "a{").to be_false
      expect(scan "a{b").to be_false
    end
    it 'deals with extra braces' do
      expect(scan "{{{").to eq("{{")
      expect(scan "{{{{").to eq("{{")
      expect(scan "{{{{{").to eq("{{")
      expect(scan "{{{{{{").to eq("{{")
     end
    it 'ignores pipes and doubleclosingbrace' do
      expect(scan "|").to be_false
      expect(scan "}}").to be_false
    end
   end
  
  describe '.a_doubleclosingbrace' do
    include ScanShortcutFor(:a_doubleclosingbrace)
    
    it 'consumes a doubleclosingbrace' do
      expect(scan "}}").to eq("}}")
      expect(scan "}}a").to eq("}}")
    end
    it 'consumes only one doubleclosingbrace even if there are others around (not greedy)' do
      expect(scan "}}a}}").to eq("}}")
     expect(scan "}}a}}a").to eq("}}")
    end
    it 'fails when there is stuff before the doubleclosingbrace' do
      expect(scan "a}}").to be_false
      expect(scan "a}}b").to be_false
    end
    it 'ignores singleclosebrace' do
      expect(scan "a}").to be_false
      expect(scan "a}b").to be_false
    end
    it 'deals with extra braces' do
      expect(scan "}}}").to eq("}}")
      expect(scan "}}}}").to eq("}}")
      expect(scan "}}}}}").to eq("}}")
      expect(scan "}}}}}}").to eq("}}")
     end
    it 'ignores pipes and doubleopenbrace' do
      expect(scan "|").to be_false
      expect(scan "{{").to be_false
    end
  end
  
  describe '.a_link' do
    include ScanShortcutFor(:a_link)
    
    it 'consumes a normal link' do
      s = scanner_after("[[foo]]")
      expect(s.matched).to eq("[[foo]]")
      expect(s[1]).to eq("foo")
      expect(s[2]).to be_nil
      expect(s[3]).to be_nil
    end
    it 'consumes only the normal link' do
      s = scanner_after("[[foo]].")
      expect(s.matched).to eq("[[foo]]")
      expect(s[1]).to eq("foo")
      expect(s[2]).to be_nil
      expect(s[3]).to be_nil
    end
    it 'consumes some extra letters after closing brackets' do
      s = scanner_after("[[foo]]nx.")
      expect(s.matched).to eq("[[foo]]nx")
      expect(s[1]).to eq("foo")
      expect(s[2]).to be_nil
      expect(s[3]).to eq("nx")
    end
    it 'consumes a link label' do
      s = scanner_after("[[foo|bar]].")
      expect(s.matched).to eq("[[foo|bar]]")
      expect(s[1]).to eq("foo")
      expect(s[2]).to eq("bar")
      expect(s[3]).to be_nil
    end
    it 'consumes a link label and extra letters' do
      s = scanner_after("[[foo|bar]]ny.")
      expect(s.matched).to eq("[[foo|bar]]ny")
      expect(s[1]).to eq("foo")
      expect(s[2]).to eq("bar")
      expect(s[3]).to eq("ny")
    end
    it 'consumes an empty link label' do
      s = scanner_after("[[foo|]].")
      expect(s.matched).to eq("[[foo|]]")
      expect(s[1]).to eq("foo")
      expect(s[2]).to eq("")
      expect(s[3]).to be_nil
    end
    it 'consumes a link with an anchor' do
      s = scanner_after("[[foo#ro|bar]]ny.")
      expect(s.matched).to eq("[[foo#ro|bar]]ny")
      expect(s[1]).to eq("foo#ro")
      expect(s[2]).to eq("bar")
      expect(s[3]).to eq("ny")
    end
    it 'does not consume unclosed links' do
      expect(scan "[[a").to be_false
    end
    it 'does not consume unclosed links with newlines' do
      expect(scan "[[a\nb]]").to be_false
    end
    it 'consume only to the first pair of brackets even if there are others around' do
      s = scanner_after("[[a]]b]]c,x")
      expect(s.matched).to eq("[[a]]b")
      expect(s[1]).to eq("a")
      expect(s[2]).to be_nil
      expect(s[3]).to eq("b")
    end
    it 'consumes pipes in the label' do
      s = scanner_after("[[a|b|c]]d,x")
      expect(s.matched).to eq("[[a|b|c]]d")
      expect(s[1]).to eq("a")
      expect(s[2]).to eq("b|c")
      expect(s[3]).to eq("d")
    end
  end
  
end