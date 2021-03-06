# Wptemplates

[![Build Status](https://travis-ci.org/bxt/wptemplates.png?branch=master)](https://travis-ci.org/bxt/wptemplates)
[![Gem Version](https://badge.fury.io/rb/wptemplates.png)](http://badge.fury.io/rb/wptemplates)

Gem for collecting template informations from mediawiki markup. 

It will help you to extract useful machine-readable data from
wikipedia articles, since there ist a lot of useful stuff
encoded as templates.

Currently only templates and links are parsed, all other markup is ignored.

## Installation

Add this line to your application's Gemfile:

    gem 'wptemplates'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wptemplates

## Usage

To parse a piece of markup simply call:

<!-- EXAMPLES:INIT -->
    ast = Wptemplates.parse("{{foo | bar | x = 3 }} baz [[bam (2003)|]]y")

<!-- /EXAMPLES -->

You will get an instance of Wptemplates::Soup which is an array of
Wptemplates::Template, Wptemplates::Link and Wptemplates::Text. 
You can explore the AST with these methods:

<!-- EXAMPLES:intro -->
    ast.templates.is_a?(Array) && ast.templates.length # => 1
    ast.text # => " baz bamy"
<!-- /EXAMPLES -->

To find template data:

<!-- EXAMPLES:templates -->
    ast[0].name # => :foo
    ast[0].params[0].text # => " bar "
    ast[0].params[:x].text # => "3"
    ast.all_templates_of(:foo).map{|t| t.params[:x].text} # => ["3"]
    ast.navigate(:foo, :x) {|p|p.text} # => "3"
    ast.navigate(:foo, :y) {|p|p.text} # => nil
<!-- /EXAMPLES -->

You can access the links via: 

<!-- EXAMPLES:links -->
    ast.links.length # => 1
    ast.links[0].text # => "bamy"
    ast.all_links.map{|l| l.link} # => ["Bam (2003)"]
<!-- /EXAMPLES -->

## Developing

Here's some useful info if you want to improve/customize this gem. 

### Getting Started

Checkout the project, run `bundle` and then `rake` to see if the tests
pass. Run `rake -T` to see the rake tasks. 

### Markup

MediaWiki markup is not trivial to parse and there might always
be compatibility issues. There's a useful help page about 
[templates][tmplh] and a [markup spec][mspec]. For links there
is a page about [links][linkh] and about the [pipe trick][ptrkh]. 
Also, there is a page with [link's BNF][lnbnf]. 

### Known Issues

* If you have images in your templates the pipes cause a new parameter
* Namespaced links are not recognized
* Templates in links are not recognized
* Links contents are not htmldecoded
* nowiki, pre and math blocks might cause problems

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[tmplh]: http://en.wikipedia.org/wiki/Help:Template#Usage_syntax "English Wikipedia Template help page, syntax section"
[mspec]: http://www.mediawiki.org/wiki/Markup_spec "MediaWiki Markup spec"
[linkh]: http://en.wikipedia.org/wiki/Help:Link "English Wikipedia Link help page"
[ptrkh]: http://en.wikipedia.org/wiki/Help:Pipe_trick "English Wikipedia Pipe trick help page"
[lnbnf]: http://www.mediawiki.org/wiki/Markup_spec/BNF/Links "MediaWiki Link BNF"
