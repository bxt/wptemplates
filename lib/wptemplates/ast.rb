module Wptemplates
  
  module Node
    def templates
      []
    end
    def all_templates
      []
    end
    def text
      ""
    end
    def templates_of type
      templates.select{|t| t.name==type}
    end
    def template_of type
      templates_of(type).first
    end
    def all_templates_of type
      all_templates.select{|t| t.name==type}
    end
    def template_of type
      all_templates_of(type).first
    end
    
  end
  
  class Soup < Array
    include Node
    def templates
      map(&:templates).flatten(1)
    end
    def all_templates
      map(&:all_templates).flatten(1)
    end
    def text
      map(&:text).join('')
    end
  end
  
  class Template
    include Node
    attr_reader :name, :params
    def initialize(name, params = {})
      @name = name
      @params = params
    end
    def templates
      [self]
    end
    def all_templates
      templates + @params.map{|_,v| v.templates }.flatten(1)
    end
  end
  
  class Text
    include Node
    attr_reader :text
    def initialize(text)
      @text = text
    end
  end
  
end
