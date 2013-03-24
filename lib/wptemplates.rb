require "wptemplates/version"
require "wptemplates/parser"
require "wptemplates/preprocessor"

module Wptemplates
  
  def self.parse text
    parser.parse(text)
    parser.parse(preprocessor.preprocess(text))
  end
  
  def self.parser
    @parser ||= Parser.new
  end
  
  def self.preprocessor
    @preprocessor ||= Preprocessor.new
  end
  
end
