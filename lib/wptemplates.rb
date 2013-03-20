require "wptemplates/version"
require "wptemplates/ast"
require "wptemplates/parser"

module Wptemplates
  
  def self.parse text
    Parser.new.parse text
  end
  
protected
  
  def self.symbolize string
    string.strip.gsub(/ /,'_').downcase.to_sym
  end

end
