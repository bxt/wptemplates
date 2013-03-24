# encoding: UTF-8

module Wptemplates
  module Regexes
    module_function
    
    def till_doublebrace_doubleopenbrackets_or_pipe
      /(
         [^{}\[|] # Unproblematic chars
      |  { (?!{ ) # A lone open brace
      |  } (?!} ) # A lone close brace
      |  \[(?!\[) # A lone open bracket
      |  ^\[\[    # Doubleopenbrackets at start
      )+/x
    end
    
    def till_doubleopenbrace_or_doubleopenbrackets
      /(
         [^{\[]   # Unproblematic chars
      |  { (?!{ ) # A lone open brace
      |  \[(?!\[) # A lone open bracket
      |  ^\[\[    # Doubleopenbrackets at start
      )+/x
    end
    
    def till_doubleclosebrace_or_pipe
      /(
         [^|}]    # Unproblematic chars
      |  } (?!} ) # A lone close brace
      )+/x
    end
    
    def from_pipe_till_equals_no_doubleclosebrace_or_pipe
      /
        \| # Pipe
        ((
         [^|=}]   # Unproblematic chars
        |}(?!})   # A lone close brace
        )*)
        = # Equals
      /x
    end
    
    def a_pipe
      /\|/
    end
    
    def a_doubleopenbrace
      /{{/
    end
    
    def a_doubleclosingbrace
      /}}/
    end
    
    def a_link
      /
        \[\[
          (?<link>
            # ([% title-legal-chars])+
            [%\ !"$&'()*,\-.\/0-9:;=?@A-Z\\^_`a-z~\u0080-\uFFFF+]+
            # ("#" [# % title-legal-chars]+)?
            ( \# [\#%\ !"$&'()*,\-.\/0-9:;=?@A-Z\\^_`a-z~\u0080-\uFFFF+]+ )?
          )
          (
            # "|" LEGAL_ARTICLE_ENTITY*
            \| (?<link-description>([^\]]|\](?!\]))*)
          )?
        \]\]
        (?<extra_letters>\p{L}*)
      /x
    end
    
    def until_hash
      /[^#]*/
    end
    
    def after_hash
      /(?<=#).*/
    end
    
    def has_parens
      /^(?<no_parens>.*?) *\(.*\) *$/
    end
    
    def first_comma
      /^(?<before>([^,]|,(?! ))*)(, |$)/
    end
    
    def parens
      /^(?<before>.*?)(\(.*\) *)?$/
    end
    
  end
end
