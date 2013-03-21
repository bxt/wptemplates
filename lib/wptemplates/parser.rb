require 'strscan'
require 'wptemplates/regexes'
require 'wptemplates/utils'
require 'wptemplates/ast'

module Wptemplates
  class Parser
    include Regexes
    include Utils
    
    def parse(text)
      @input = StringScanner.new(text)
      parse_main
    end
    
  protected
    
    def parse_main in_template_parameter = false
      output = Soup.new

      while unit = parse_link || parse_template || parse_anything(in_template_parameter)
        output << unit
      end
      
      output << Text.new("") if output.empty?

      output
    end
    
    def parse_template
      if @input.scan(a_doubleopenbrace)
        template = Template.new parse_template_name, parse_template_parameters
        @input.scan(a_doubleclosingbrace) or raise "unclosed template"
        template
      end
    end
    
    def parse_anything in_template_parameter = false
      if in_template_parameter
        @input.scan(till_doublebrace_or_pipe) && Text.new(@input.matched)
      else
        @input.scan(till_doubleopenbrace) && Text.new(@input.matched)
      end
    end
    
    def parse_template_name
      if @input.scan(till_doubleclosebrace_or_pipe)
        symbolize(@input.matched)
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
      if @input.scan(from_pipe_till_equals_no_doubleclosebrace_or_pipe)
        key = symbolize(@input[1])
        value = parse_main(true)
        value[ 0].text.lstrip!
        value[-1].text.rstrip!
        h[key] = value
      end
    end
    
    def parse_numeric_template_parameter(h,i)
      if @input.scan(a_pipe)
        value = parse_main(true)
        h[i] = value
      end
    end
    
    def parse_link
      if @input.scan(a_link)
        url, label, letters = (1..3).map {|i| @input[i]}
        if label == ""
          pipe_trick url, label, letters
        else
          link_new_with_normalize "#{label || url}#{letters}", url[until_hash], url[after_hash]
        end
      end
    end
    
    def pipe_trick url, label, letters
      if url["#"]
        nil
      elsif m = has_parens.match(url)
        link_new_with_normalize(m[:no_parens], url, nil)
      else
        label = fixpoint(clone: true, start: url.clone) do |u|
          u[last_comma,:before][parens, :before]
        end
        link_new_with_normalize("#{label}#{letters}", url, nil)
      end
    end
    
    def link_new_with_normalize text, link, anchor
      text = normalize_linklabel(text)
      link = normalize_link(link)
      anchor = normalize_link(anchor, true) unless anchor.nil?
      Link.new(text, link, anchor)
    end
    
  end
end
