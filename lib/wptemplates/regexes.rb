module Wptemplates
  module Regexes
    
    def till_doublebrace_or_pipe
      /([^{}|]|{(?!{)|}(?!}))+/
    end
    
    def till_doubleopenbrace
      /([^{]|{(?!{))+/
    end
    
    def till_doubleclosebrace_or_pipe
      /([^|}]|}(?!}))+/
    end
    
    def an_equals_no_doubleclosebrace_or_pipe
      /\|(([^|=}]|}(?!}))+)=/
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
    
  end
end
