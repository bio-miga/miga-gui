require "rake/testtask"

SOURCES = FileList["lib/**/*.rb"]

desc "Default Task"
task :default => "test:all"

Rake::TestTask.new("test:all") do |t|
  t.libs << "test"
  t.pattern = "test/*_test.rb"
  t.verbose = true
end
