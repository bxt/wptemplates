require "wptemplates/version"
require "wptemplates/parser"

module Wptemplates
  
  def self.parse text
    parser.parse(text)
  
  def self.parser
    @parser ||= Parser.new
  end
  
end
