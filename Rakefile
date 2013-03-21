require "bundler/gem_tasks"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new('spec')

task :default => :spec

task :spec => 'spec/examples_spec.rb'

task 'spec/examples_spec.rb' => 'README.md' do
  puts "Regenerating spec/examples_spec.rb"
  readme = File.open('README.md'){ |f| f.read }
  test = "require 'spec_helper'\n\ndescribe 'examples' do\n\n"
  readme.scan(/<\!-- *EXAMPLES:(.*?) *-->(.*?)<\!-- *\/EXAMPLES *-->/m) do |name,code|
    if name == "INIT"
      test << code
    else
      test << "  it '#{name}' do\n"
      code.lines.each do |l|
        / *(?<actual>.*?) *#=> *(?<expected>.*)/.match(l) do |m|
          test << "    expect(#{m[:actual]}).to eq(#{m[:expected]})\n"
        end
      end
      test << "  end\n"
    end
  end
  test << "\nend\n"
  File.open('spec/examples_spec.rb','w'){ |f| f.puts test }
end


require 'rdoc/task'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Wptemplates'
  rdoc.options << '--line-numbers'
  rdoc.main = 'README.rdoc'
  rdoc.rdoc_files.include('README.rdoc', 'lib/**/*.rb')
end



desc "Open an irb session preloaded with wptemplates library"
task :console do
  sh "irb -rubygems -I lib -r ./lib/wptemplates.rb"
end
