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
  require 'project_details'
  require 'prattle/parser'
  gr = KPeg::GrammarRenderer.new(RLK::Project::Parser::Grammar)
  gr.render(STDOUT)
end
