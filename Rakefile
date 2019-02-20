require 'rake'
require 'rspec'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

desc 'Test the develop version'
task :test_dev do
  ENV['CANTALOUPE_VERSION'] = 'dev'
  RSpec::Core::Runner.run(['spec/cantaloupe_spec.rb'])
end

desc 'Test the stable version'
task :test_stable do
  ENV['CANTALOUPE_VERSION'] = 'stable'
  RSpec::Core::Runner.run(['spec/cantaloupe_spec.rb'])
end

# Run our docker-cantaloupe tests with different ENVs
task default: %i[rubocop test]

desc 'Run tests'
task(:test) do
  ENV['CANTALOUPE_VERSION'] = 'stable'
  RSpec::Core::Runner.run(['spec/cantaloupe_spec.rb'])
  RSpec.clear_examples
  ENV['CANTALOUPE_VERSION'] = 'dev'
  RSpec::Core::Runner.run(['spec/cantaloupe_spec.rb'])
end

desc 'Run rubocop'
task :rubocop do
  RuboCop::RakeTask.new
end

# Let's throw in a few aliases
task spec: :default
task rspec: :default
