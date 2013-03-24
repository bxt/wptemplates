
module Wptemplates
  class Preprocessor
    
    def preprocess(text)
      strip_html_comments!(text)
      text
    end
    
  protected
    
    def strip_html_comments!(text)
      text.gsub!(/<!--.*?-->/m,'')
    end
    
  end
end
