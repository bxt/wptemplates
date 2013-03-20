module Wptemplates
  module Utils
    module_function
    
    def normalize_link string
      string.tr('_',' ').strip.squeeze(' ').capitalize
    end
    
    def symbolize string
      normalize_link(string).gsub(' ','_').downcase.to_sym
    end
    
  end
end
