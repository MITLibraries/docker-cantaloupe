require 'dockerspec/serverspec'
require 'dockerspec/infrataster'
require 'spec_helper'

# Define some basic variables
reg_username = ENV.has_key?('REG_USERNAME') ? ENV['REG_USERNAME'] + '/' : ''
version = ENV['CANTALOUPE_VERSION']
docker_env = { 'ENDPOINT_ADMIN_SECRET' => 'secret', 'ENDPOINT_ADMIN_ENABLED' => 'true' }
dockerfile = create_test_dockerfile(reg_username)
image_tag = reg_username + 'cantaloupe_' + version 

# First we build either a 'stable' or 'dev' Cantaloupe image, depending on our ENV property
if version == 'stable'
  expected_version = '4.0.3'

  describe docker_build('.', tag: image_tag)
elsif version == 'dev'
  commit_ref = ENV.has_key?('COMMIT_REF') ? '--build-arg COMMIT_REF=' + ENV['COMMIT_REF'] : ''
  expected_version = '4.1-SNAPSHOT'

  # Build the _dev version of cantaloupe by calling docker here via a system call
  # this is required because we need to use --build-arg, and DockerSpec does not
  # currently support --build-ARG, see https://github.com/zuazo/dockerspec/issues/14
  system("docker build --build-arg 'CANTALOUPE_VERSION=latest' " + commit_ref + " -t " + image_tag + " .")
else
  raise('No CANTALOUPE_VERSION set')
end

# Next, we build a test Cantaloupe image so we can run our tests against it.
# We do this so we can install additional things that are useful for testing
describe docker_build(dockerfile, tag: image_tag + '_test') do
  it { should have_expose '8182' }

  describe docker_run(image_tag + '_test', env: docker_env, wait: 60) do
    describe server(described_container) do
      describe port('8182') do
        it { should be_listening.with('tcp') }
      end

      describe http('http://localhost:8182') do
        it 'contains "Cantaloupe Image Server"' do
          expect(response.body).to match(/Cantaloupe Image Server/)
        end

        it 'does not contain "Oops"' do
          expect(response.body).to_not match(/Oops/i)
        end

        it 'contains the expected version number, ' + expected_version do
          expect(response.body).to match('Cantaloupe Image Server <small>' + expected_version + '</small>')
        end
      end

      describe file('/etc/cantaloupe.properties') do
        it { should be_file }
        it { should be_mode 644 }
        it { should be_owned_by 'cantaloupe'}
        it { should be_grouped_into 'root' }
      end
    end
  end
end
