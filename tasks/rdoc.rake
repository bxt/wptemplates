require 'rdoc/task'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Wptemplates'
  rdoc.options << '--line-numbers'
  rdoc.main = 'README.rdoc'
  rdoc.rdoc_files.include('README.rdoc', 'lib/**/*.rb')
end

namespace :rdoc do
  desc "Open the rdocs in browser"
  task :open => [:rdoc, :browser] do
    sh "#{ENV["DEVELOPMENT_WEBBROWSER"]} rdoc/index.html"
  end
end
