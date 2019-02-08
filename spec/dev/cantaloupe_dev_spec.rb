require 'dockerspec/serverspec'
require 'dockerspec/infrataster'

RSpec.configure do |config|
  config.log_level = :ci
  config.docker_wait = 60
end

### test cantaloupe_dev (i.e. the bleeding-edge/develop build)

commit_ref = ENV.has_key?('COMMIT_REF') ? '--build-arg COMMIT_REF=' + ENV['COMMIT_REF'] : ''

# Build the _dev version of cantaloupe by calling docker here via a system call
# this is required because we need to use --build-arg, and DockerSpec does not
# currently support --build-ARG, see https://github.com/zuazo/dockerspec/issues/14
system("docker build --build-arg 'CANTALOUPE_VERSION=latest' " + commit_ref +
  " -t uclalibrary/cantaloupe_dev .")

# the system command is supposed to be synchronous... so... hopefully we'll wait
# until it's done before continuing on?

# Note, this build assumes that the cantaloupe_stable test works, so run it first
  describe docker_build('spec/dev/', tag: 'uclalibrary/cantaloupe_dev_test') do
    docker_env = {  'CANTALOUPE_VERSION' => 'latest',
                    'ENDPOINT_ADMIN_SECRET' => 'secret',
                    'ENDPOINT_ADMIN_ENABLED' => 'true' }
    wait = ENV['TRAVIS'] ? 10 : 2

    describe docker_run('uclalibrary/cantaloupe_dev_test', env: docker_env, wait: 120) do
      ### refactor, what packages? does it even matter?
      # describe package('nodejs') do
      #   it { should be_installed }
      # end
      ### refactor, what commands make sense to run?
      # it 'has node in the path' do
      #   expect(command('which node || which nodejs').exit_status).to eq 0
      # end
      ### refactor, what processes should be running?
      # describe process('su -m -l dradis -c exec bundle exec rails server') do
      #   it { should be_running }
      # end

      describe port('8182') do
        it { should be_listening }
      end

      describe server(described_container) do
        describe http('http://localhost:8182/') do
          it 'contains "Cantaloupe Image Server"' do
            expect(response.body).to match(/Cantaloupe Image Server/)
          end

          it 'does not contain "Oops"' do
            expect(response.body).to_not match(/Oops/i)
          end

          it 'contains the expected version number, 4.1-SNAPSHOT' do
            expect(response.body).to match(/Cantaloupe Image Server \<small\>4.1-SNAPSHOT\<\/small\>/)
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
