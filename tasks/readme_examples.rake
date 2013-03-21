
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
        (/^ *(?<actual>.*?) *# *=> *(?<expected>.*)$/.match(l) do |m|
          test << "    expect(#{m[:actual]}).to eq(#{m[:expected]})\n"
        end) || /^\s+(#.*)?$/.match(l) || puts("\033[31mLinie not well formed: \033[0m", l)
      end
      test << "  end\n"
    end
  end
  test << "\nend\n"
  File.open('spec/examples_spec.rb','w'){ |f| f.puts test }
end
