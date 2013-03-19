require 'strscan'
require "wptemplates/version"

module Wptemplates
  class Parser
    
    def parse(text)
      @input = StringScanner.new(text)
      parse_main
    end
    
  protected
    
    def parse_main in_template_parameter = false
      output = Soup.new

      while unit = parse_template || parse_anything(in_template_parameter)
        output << unit
      end

      output
    end
    
    def parse_template
      if @input.scan(/{{/)
        template = Template.new parse_template_name, parse_template_parameters
        @input.scan(/}}/) or raise "unclosed template"
        template
      else
        nil
      end
    end
    
    def parse_anything in_template_parameter = false
      if in_template_parameter
        @input.scan(/([^{}|]|{(?!{)|}(?!}))+/) && Text.new(@input.matched)
      else
        @input.scan(/([^{]|{(?!{))+/) && Text.new(@input.matched)
      end
    end
    
    def parse_template_name
      if @input.scan(/([^|}]|}(?!}))+/)
        symbolize(@input.matched)
      else
        nil
      end
    end
    
    def parse_template_parameters
      i = 0
      h = {}
      while parsed_named_template_parameter(h) || parse_numeric_template_parameter(h,i) do
        i += 1
      end
      h
    end
    
    def parsed_named_template_parameter(h)
      if @input.scan(/\|(([^|=}]|}(?!}))+)=/)
        key = symbolize(@input[1])
        value = parse_main(true)
        value[ 0].text.lstrip!
        value[-1].text.rstrip!
        h[key] = value
      else
        nil
      end
    end
    
    def parse_numeric_template_parameter(h,i)
      if @input.scan(/\|/)
        value = parse_main(true)
        h[i] = value
      else
        nil
      end
    end
    
    def symbolize string
      Wptemplates.symbolize string
    end
    
  end
end
