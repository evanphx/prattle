require 'rake/testtask'

$:.unshift "lib"

task :default => :test

desc "Run tests"
Rake::TestTask.new do |t|
  t.libs = ["lib"]
  t.test_files = FileList['test/test*.rb'] + FileList["test/ast/test*.rb"]
  t.verbose = true
end

task :grammar do
  require 'prattle/parser'
  gr = KPeg::GrammarRenderer.new(Prattle::Parser::Grammar)
  gr.render(STDOUT)
end
