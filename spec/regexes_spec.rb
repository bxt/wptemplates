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

  describe '.till_doublebrace_doubleopenbrackets_or_pipe' do
    include ScanShortcutFor(:till_doublebrace_doubleopenbrackets_or_pipe)

    it 'consumes a string with no doublebraces or doubleopenbrackets or pipes at all' do
      expect(scan "abc").to eq("abc")
    end
    it 'consumes until doublebraces or doubleopenbrackets or pipe' do
      expect(scan "abc{{d").to eq("abc")
      expect(scan "abc|d").to eq("abc")
      expect(scan "abc}}d").to eq("abc")
      expect(scan "abc[[d").to eq("abc")
    end
     it 'ignores starting doubleopenbrackets' do
      expect(scan "[[abc").to eq("[[abc")
      expect(scan "[[abc{{d").to eq("[[abc")
      expect(scan "[[abc|d").to eq("[[abc")
      expect(scan "[[abc}}d").to eq("[[abc")
      expect(scan "[[abc[[d").to eq("[[abc")
    end
   it 'does not accept an empty string (epsilon transition)' do
      expect(scan "{{d").to be_falsey
      expect(scan "|d").to be_falsey
      expect(scan "}}d").to be_falsey
    end
    it 'consumes until doublebraces or doubleopenbrackets or pipe even if other braces and pipes show up (not greedy)' do
      expect(scan "ab|c{{d}}e").to eq("ab")
      expect(scan "ab|c|d|e").to eq("ab")
      expect(scan "ab{{c|d}}e").to eq("ab")
      expect(scan "ab}}c|d{{e").to eq("ab")
      expect(scan "ab[[c|d}}e").to eq("ab")
      expect(scan "ab[[c|d{{e").to eq("ab")
    end
    it 'ignores lone braces' do
      expect(scan "ab{c|d}}e").to eq("ab{c")
      expect(scan "ab}c|d{{e").to eq("ab}c")
    end
    it 'ignores lone openbrackets' do
      expect(scan "ab[c|d}}e").to eq("ab[c")
    end
    it 'ignores closebrackets' do
      expect(scan "ab]]c|d}}e").to eq("ab]]c")
    end
  end

  describe '.till_doubleopenbrace_or_doubleopenbrackets' do
    include ScanShortcutFor(:till_doubleopenbrace_or_doubleopenbrackets)

    it 'consumes a string with no doubleopenbraces or doubleopenbrackets at all' do
      expect(scan "abc").to eq("abc")
      expect(scan "ab}}c").to eq("ab}}c")
      expect(scan "ab|c").to eq("ab|c")
      expect(scan "ab]]c").to eq("ab]]c")
    end
    it 'consumes until doubleopenbraces' do
      expect(scan "abc{{d").to eq("abc")
      expect(scan "abc|d{{").to eq("abc|d")
      expect(scan "abc}}d{{").to eq("abc}}d")
    end
    it 'ignores starting doubleopenbrackets' do
      expect(scan "[[abc").to eq("[[abc")
      expect(scan "[[abc{{d").to eq("[[abc")
      expect(scan "[[abc|d{{").to eq("[[abc|d")
      expect(scan "[[abc}}d{{").to eq("[[abc}}d")
    end
    it 'consumes until doubleopenbrackets' do
      expect(scan "abc[[d").to eq("abc")
      expect(scan "abc|d[[").to eq("abc|d")
      expect(scan "abc]]d[[").to eq("abc]]d")
    end
    it 'does not accept an empty string (epsilon transition)' do
      expect(scan "{{d").to be_falsey
    end
    it 'consumes until doubleopenbraces/brackets if other doubleopenbraces/brackets show up (not greedy)' do
      expect(scan "ab{{d{{e").to eq("ab")
      expect(scan "ab[[d{{e").to eq("ab")
      expect(scan "ab[[d[[e").to eq("ab")
      expect(scan "ab{{d[[e").to eq("ab")
    end
    it 'ignores lone braces and brackets' do
      expect(scan "ab[{c{{e").to eq("ab[{c")
      expect(scan "ab[{c[[e").to eq("ab[{c")
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
      expect(scan "}}d").to be_falsey
      expect(scan "|d").to be_falsey
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
        expect(scan "|abc}}d=e").to be_falsey
        expect(scan "|a{{bc}}d=e").to be_falsey
      end
      it 'ignores single closebraces' do
        expect(scan "|abc}d=e").to eq("|abc}d=")
        expect(scan "|a{{bc}d=e").to eq("|a{{bc}d=")
      end
      it 'fails when a pipe occurs before equals' do
        expect(scan "|abc|d=e").to be_falsey
        expect(scan "|a{{bc|d=e").to be_falsey
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
        expect(scan "|abc").to be_falsey
      end
      it 'fails when there is a pipe' do
        expect(scan "abc|d").to be_falsey
        expect(scan "abcd|").to be_falsey
        expect(scan "|abcd").to be_falsey
      end
      it 'fails when there are doubleclosebraces' do
        expect(scan "abc}}d").to be_falsey
        expect(scan "abcd}}").to be_falsey
        expect(scan "}}abcd").to be_falsey
      end
    end
    context 'when the pipe is not a the beginning or there is no pipe' do
      it 'fails' do
        expect(scan "abc").to be_falsey
        expect(scan "abc=").to be_falsey
        expect(scan "a|bc=d").to be_falsey
        expect(scan " |bc=d").to be_falsey
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
      expect(scan "a|").to be_falsey
      expect(scan "a|b").to be_falsey
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
      expect(scan "a{{").to be_falsey
      expect(scan "a{{b").to be_falsey
    end
    it 'ignores singleopenbrace' do
      expect(scan "a{").to be_falsey
      expect(scan "a{b").to be_falsey
    end
    it 'deals with extra braces' do
      expect(scan "{{{").to eq("{{")
      expect(scan "{{{{").to eq("{{")
      expect(scan "{{{{{").to eq("{{")
      expect(scan "{{{{{{").to eq("{{")
     end
    it 'ignores pipes and doubleclosingbrace' do
      expect(scan "|").to be_falsey
      expect(scan "}}").to be_falsey
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
      expect(scan "a}}").to be_falsey
      expect(scan "a}}b").to be_falsey
    end
    it 'ignores singleclosebrace' do
      expect(scan "a}").to be_falsey
      expect(scan "a}b").to be_falsey
    end
    it 'deals with extra braces' do
      expect(scan "}}}").to eq("}}")
      expect(scan "}}}}").to eq("}}")
      expect(scan "}}}}}").to eq("}}")
      expect(scan "}}}}}}").to eq("}}")
     end
    it 'ignores pipes and doubleopenbrace' do
      expect(scan "|").to be_falsey
      expect(scan "{{").to be_falsey
    end
  end

  describe '.a_link' do
    include ScanShortcutFor(:a_link)

    it 'consumes a normal link' do
      s = scanner_after("[[foo]]")
      expect(s.matched).to eq("[[foo]]")
      expect(s[1]).to eq("foo")
      expect(s[2]).to be_nil
      expect(s[3]).to eq("")
    end
    it 'consumes only the normal link' do
      s = scanner_after("[[foo]].")
      expect(s.matched).to eq("[[foo]]")
      expect(s[1]).to eq("foo")
      expect(s[2]).to be_nil
      expect(s[3]).to eq("")
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
      expect(s[3]).to eq("")
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
      expect(s[3]).to eq("")
    end
    it 'consumes a link with an anchor' do
      s = scanner_after("[[foo#ro|bar]]ny.")
      expect(s.matched).to eq("[[foo#ro|bar]]ny")
      expect(s[1]).to eq("foo#ro")
      expect(s[2]).to eq("bar")
      expect(s[3]).to eq("ny")
    end
    it 'does not consume unclosed links' do
      expect(scan "[[a").to be_falsey
    end
    it 'does not consume unclosed links with newlines' do
      expect(scan "[[a\nb]]").to be_falsey
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
    it 'consumes single brackets in the label' do
      s = scanner_after("[[a|b]c]]d,x")
      expect(s.matched).to eq("[[a|b]c]]d")
      expect(s[1]).to eq("a")
      expect(s[2]).to eq("b]c")
      expect(s[3]).to eq("d")
    end
    it 'consumes parens in urls' do
      s = scanner_after("[[a(b)|c]]d.")
      expect(s.matched).to eq("[[a(b)|c]]d")
      expect(s[1]).to eq("a(b)")
      expect(s[2]).to eq("c")
      expect(s[3]).to eq("d")
    end
    it 'consumes commas in urls' do
      s = scanner_after("[[a,b|c]]d.")
      expect(s.matched).to eq("[[a,b|c]]d")
      expect(s[1]).to eq("a,b")
      expect(s[2]).to eq("c")
      expect(s[3]).to eq("d")
    end
    it 'consumes spaces in urls' do
      s = scanner_after("[[ ]]")
      expect(s.matched).to eq("[[ ]]")
      expect(s[1]).to eq(" ")
      expect(s[2]).to be_nil
      expect(s[3]).to eq("")
    end
  end

  describe '.until_hash' do
    it 'prints the part to the first hash, excluding' do
      expect("abc#def"[subject.until_hash]).to eq("abc")
      expect("abc#d#ef"[subject.until_hash]).to eq("abc")
      expect("abc#def#"[subject.until_hash]).to eq("abc")
      expect("abc#"[subject.until_hash]).to eq("abc")
    end
    it 'prints everything if there is no hash' do
      expect("abc"[subject.until_hash]).to eq("abc")
    end
  end

  describe '.after_hash' do
    it 'prints the part after the first hash, excluding' do
      expect("abc#def"[subject.after_hash]).to eq("def")
      expect("abc#d#ef"[subject.after_hash]).to eq("d#ef")
      expect("abc#def#"[subject.after_hash]).to eq("def#")
      expect("abc#"[subject.after_hash]).to eq("")
    end
    it 'returns nil if there is no hash' do
      expect("abc"[subject.after_hash]).to be_nil
    end
  end

  describe '.has_parens' do
    it 'detects if there are matching parens at the end' do
      expect("abc(def)"[subject.has_parens]).to be_truthy
      expect("abc (def)"[subject.has_parens]).to be_truthy
      expect("abc (def) "[subject.has_parens]).to be_truthy
      expect("abc(def) "[subject.has_parens]).to be_truthy
      expect("abc(d(ef)"[subject.has_parens]).to be_truthy
      expect("abc(d(e)f)"[subject.has_parens]).to be_truthy
      expect("abc(d(ef)"[subject.has_parens]).to be_truthy
      expect("abc(d)e(f)"[subject.has_parens]).to be_truthy
      expect("abc(def"[subject.has_parens]).to be_falsey
      expect("abc)def"[subject.has_parens]).to be_falsey
      expect("abc"[subject.has_parens]).to be_falsey
    end
    it 'returns the part without parens as :no_parens' do
      expect("abc(def)"[subject.has_parens, :no_parens]).to eq("abc")
      expect("abc (def)"[subject.has_parens, :no_parens]).to eq("abc")
      expect("abc (def) "[subject.has_parens, :no_parens]).to eq("abc")
      expect("abc(def) "[subject.has_parens, :no_parens]).to eq("abc")
      expect("abc(d(ef)"[subject.has_parens, :no_parens]).to eq("abc")
      expect("abc(d(e)f)"[subject.has_parens, :no_parens]).to eq("abc")
      expect("abc(d(ef)"[subject.has_parens, :no_parens]).to eq("abc")
      expect("abc(d)e(f)"[subject.has_parens, :no_parens]).to eq("abc")
      expect("abc(def"[subject.has_parens, :no_parens]).to be_nil
      expect("abc)def"[subject.has_parens, :no_parens]).to be_nil
      expect("abc"[subject.has_parens, :no_parens]).to be_nil
    end
  end

  describe '.first_comma' do
    it 'returns the part before the first comma and space, excluding, as :before' do
      expect("abc, def"[subject.first_comma, :before]).to eq("abc")
      expect("abc, def, ghi"[subject.first_comma, :before]).to eq("abc")
      expect("abc def"[subject.first_comma, :before]).to eq("abc def")
      expect("abc,def"[subject.first_comma, :before]).to eq("abc,def")
      expect("abc,"[subject.first_comma, :before]).to eq("abc,")
      expect(",abc"[subject.first_comma, :before]).to eq(",abc")
      expect(", abc"[subject.first_comma, :before]).to eq("")
      expect("a, , b"[subject.first_comma, :before]).to eq("a")
    end
  end

  describe '.first_comma' do
    it 'returns the part before the matching parens at the end as :before' do
      expect("abc(def)"[subject.parens, :before]).to eq("abc")
      # different whitespace behaviour not to loose any valid ", "
      expect("abc (def)"[subject.parens, :before]).to eq("abc ")
      expect("abc (def) "[subject.parens, :before]).to eq("abc ")
      expect("abc(def) "[subject.parens, :before]).to eq("abc")
      expect("abc(d(ef)"[subject.parens, :before]).to eq("abc")
      expect("abc(d(e)f)"[subject.parens, :before]).to eq("abc")
      expect("abc(d(ef)"[subject.parens, :before]).to eq("abc")
      expect("abc(d)e(f)"[subject.parens, :before]).to eq("abc")
      expect("abc(def"[subject.parens, :before]).to eq("abc(def")
      expect("abc)def"[subject.parens, :before]).to eq("abc)def")
      expect("abc"[subject.parens, :before]).to eq("abc")
    end
  end

end
