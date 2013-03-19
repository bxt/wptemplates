# Wptemplates

Gem for collecting template informations from mediawiki markup. 

## Installation

Add this line to your application's Gemfile:

    gem 'wptemplates', git: 'git://github.com/bxt/wptemplates.git'

And then execute:

    $ bundle

The gem is currently not in the rubygems.org repository. 

## Usage

To parse a piece of markup simply call:

<!-- EXAMPLES:INIT -->
    ast = Wptemplates.parse("{{foo | bar | x = 3 }} baz")

<!-- /EXAMPLES -->

You will get an instance of Wptemplates::Soup which is an array of
Wptemplates::Template and Wptemplates::Text. You can explore the AST with
these methods:

<!-- EXAMPLES:intro -->
    ast.templates.is_a?(Array) && ast.templates.length #=> 1
    ast.text #=> " baz"
    ast[0].name #=> :foo
    ast[0].params[0].text #=> " bar "
    ast[0].params[:x].text #=> "3"
    ast.all_templates_of(:foo).map{|t| t.params[:x].text} => ["3"]
<!-- /EXAMPLES -->

## Developing

### Known Issues

* If you have link in your templates the pipes cause a new parameter
* nowiki, pre and math blocks are deleted

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
