
begin
  
  require 'redcarpet'

  task 'README.html' => 'README.md' do
    puts "Regenerating README.html"
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true)
    html = markdown.render(File.open('README.md'){ |f| f.read })
    File.open('README.html','w'){ |f| f.puts html }
  end

  namespace :readme do
    desc "Open the README in browser"
    task :open => ['README.html', :browser] do
      sh "#{ENV["DEVELOPMENT_WEBBROWSER"]} README.html"
    end
  end

rescue LoadError
  puts "Could not load redcarpet. The README.md rake tasks are not available."
end
