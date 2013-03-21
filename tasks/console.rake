
desc "Open an irb session preloaded with wptemplates library"
task :console do
  sh "irb -rubygems -I lib -r ./lib/wptemplates.rb"
end
