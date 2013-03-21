module Wptemplates
  module Utils
    module_function
    
    def normalize_link string, anchor = false
      normalized = string.clone
      normalized.tr!('_',' ')
      normalized.strip!
      normalized.squeeze!(' ')
      normalized[0] = normalized[0,1].upcase unless anchor
      normalized
    end
    
    def normalize_linklabel string
      normalized = string.clone
      normalized.strip!
      normalized.squeeze!(' ')
      normalized
    end
    
    def symbolize string
      symbolized = normalize_link(string)
      symbolized.tr!(' ','_')
      symbolized.downcase.to_sym
    end
    
    def fixpoint start = nil
      cur = start
      begin
        pre = cur
        cur = yield(cur)
      end while cur != pre
      cur
    end
    
  end
end
