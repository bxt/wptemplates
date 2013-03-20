module Wptemplates
  module Utils
    module_function
    
    def symbolize string
      string.strip.gsub(/ /,'_').downcase.to_sym
    end
    
  end
end
