require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "yard"
require 'rubocop/rake_task'

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new(:spec)

task default: :spec

YARD::Rake::YardocTask.new do |t|
  t.files = ["lib/**/*.rb"]
  t.options = []
  t.stats_options = ["--list-undoc"]
end
