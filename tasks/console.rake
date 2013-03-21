desc "Open an irb session preloaded with wptemplates library"
task :console do
  ARGV.clear
  ARGV.push "-f", "-I", "lib", "-r", "./tasks/irbrc"
  require 'irb'
  IRB.start
end
