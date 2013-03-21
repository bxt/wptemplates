require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

namespace :spec do
  desc "Open coverage report in browser"
  task :open_coverage => :browser do
    sh "#{ENV["DEVELOPMENT_WEBBROWSER"]} coverage/index.html"
  end
end
