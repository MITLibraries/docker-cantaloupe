require 'tmpdir'
require 'erb'

RSpec.configure do |config|
  config.log_level = :ci
  config.docker_wait = 60

  original_stderr = $stderr
  original_stdout = $stdout

  config.before(:all) do
    # Redirect stderr and stdout
    $stderr = File.open(File::NULL, 'w')
    $stdout = File.open(File::NULL, 'w')
  end

  config.after(:all) do
    $stderr = original_stderr
    $stdout = original_stdout
  end
end

def save_dockerfile(file, content)
  File.open(file, 'w+') do |f|
    f.write(content)
  end
end

def create_test_dockerfile(reg_username)
  template = File.read('spec/Dockerfile.erb')
  cantaloupe_version = ENV['CANTALOUPE_VERSION']
  erb = ERB.new(template)
  dockerfile_content = erb.result(binding)
  tmp_dockerfile = Dir.mktmpdir + '/Dockerfile'
  puts 'creating test dockerfile for cantaloupe version: ' + cantaloupe_version + ' [' + tmp_dockerfile + ']'
  save_dockerfile(tmp_dockerfile, dockerfile_content)
  tmp_dockerfile
end
