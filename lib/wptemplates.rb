require "wptemplates/version"
require "wptemplates/parser"

module Wptemplates
  
  def self.parse text
    Parser.new.parse text
  end
  
end
