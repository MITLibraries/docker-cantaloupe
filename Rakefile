require 'rake'
require 'rspec'
require 'rspec/core/rake_task'

task :test_dev do
  ENV['CANTALOUPE_VERSION'] = 'dev'
  RSpec::Core::Runner.run(['spec/cantaloupe_spec.rb'])
end

task :test_stable do
  ENV['CANTALOUPE_VERSION'] = 'stable'
  RSpec::Core::Runner.run(['spec/cantaloupe_spec.rb'])
end

# Run our docker-cantaloupe tests with different ENVs
task :default => [] do
  ENV['CANTALOUPE_VERSION'] = 'stable'
  RSpec::Core::Runner.run(['spec/cantaloupe_spec.rb'])
  RSpec.clear_examples
  ENV['CANTALOUPE_VERSION'] = 'dev'
#  ENV['COMMIT_REF'] = ''
  RSpec::Core::Runner.run(['spec/cantaloupe_spec.rb'])
end

# Let's throw in a few aliases
task :test => :default
task :spec => :default
task :rspec => :default
