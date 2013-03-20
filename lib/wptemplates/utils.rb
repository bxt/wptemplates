module Wptemplates
  module Utils
    module_function
    
    def normalize_link string
      normalized = string.clone
      normalized.tr!('_',' ')
      normalized.strip!
      normalized.squeeze!(' ')
      normalized[0] = normalized[0,1].upcase
      normalized
    end
    
    def symbolize string
      symbolized = normalize_link(string)
      symbolized.tr!(' ','_')
      symbolized.downcase.to_sym
    end
    
  end
end
