module Wptemplates
  module Regexes
    module_function
    
    def till_doublebrace_or_pipe
      /([^{}|]|{(?!{)|}(?!}))+/
    end
    
    def till_doubleopenbrace
      /([^{]|{(?!{))+/
    end
    
    def till_doubleclosebrace_or_pipe
      /([^|}]|}(?!}))+/
    end
    
    def from_pipe_till_equals_no_doubleclosebrace_or_pipe
      /\|(([^|=}]|}(?!}))*)=/
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
      /\[\[(?<link>[%!"$&'()*,\-.\/0-9:;=?@A-Z\\^_`a-z~\u0080-\uFFFF+]+(?:#[#%!"$&'()*,\-.\/0-9:;=?@A-Z\\^_`a-z~\u0080-\uFFFF+]+)?)(\|(?<link-description>([^]]|\](?!\]))+))?\]\](?<extra_letters>\p{L}+)?/
    end
    
  end
end
