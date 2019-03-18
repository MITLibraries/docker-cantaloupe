require 'dockerspec/serverspec'
require 'dockerspec/infrataster'
require 'spec_helper'

# Define some basic variables
reg_username = ENV.key?('REG_USERNAME') ? ENV['REG_USERNAME'] + '/' : ''
version = ENV['CANTALOUPE_VERSION']
docker_env = { 'ENDPOINT_ADMIN_SECRET' => 'secret', 'ENDPOINT_ADMIN_ENABLED' => 'true' }
dockerfile = create_test_dockerfile(reg_username)
image_tag = reg_username + 'cantaloupe_' + version

# First we build either a 'stable' or 'dev' Cantaloupe image, depending on our ENV property
if version == 'stable'
  expected_version = '4.0.3'

  describe docker_build('.', tag: image_tag)
elsif version == 'dev'
  commit_ref = ENV.key?('COMMIT_REF') ? ' --build-arg COMMIT_REF=' + ENV['COMMIT_REF'] + ' ' : ' '
  expected_version = '4.1-SNAPSHOT'

  # Build the _dev version of cantaloupe by calling docker here via a system call
  # this is required because we need to use --build-arg, and DockerSpec does not
  # currently support --build-ARG, see https://github.com/zuazo/dockerspec/issues/14
  success = system('docker build --build-arg CANTALOUPE_VERSION=' + version + commit_ref + '-t ' + image_tag + ' .')
  raise 'Failed to create dev docker-cantaloupe container for testing' unless success
else
  raise('No CANTALOUPE_VERSION set')
end

# Next, we build a test Cantaloupe image so we can run our tests against it.
# We do this so we can install additional things that are useful for testing
describe docker_build(dockerfile, tag: image_tag + '_test') do
  it { is_expected.to have_expose '8182' }

  describe docker_run(image_tag + '_test', env: docker_env, wait: 60) do
    describe server(described_container) do
      describe port('8182') do
        it { is_expected.to be_listening.with('tcp') }
      end

      describe http('http://localhost:8182') do
        it 'contains "Cantaloupe Image Server"' do
          expect(response.body).to match(/Cantaloupe Image Server/)
        end

        it 'does not contain "Oops"' do
          expect(response.body).not_to match(/Oops/i)
        end

        it 'contains the expected version number, ' + expected_version do
          expect(response.body).to match('Cantaloupe Image Server <small>' + expected_version + '</small>')
        end
      end

      describe file('/etc/cantaloupe.properties') do
        it { is_expected.to be_file }
        it { is_expected.to be_mode 644 }
        it { is_expected.to be_owned_by 'cantaloupe' }
        it { is_expected.to be_grouped_into 'root' }
      end

      # dpkg -s libopenjp2-tools openjdk-11-jre-headless wget unzip graphicsmagick curl imagemagick ffmpeg
      describe package('libopenjp2-tools') do
        it { is_expected.to be_installed.with_version('2.3.0-1') }
      end

      describe package('openjdk-11-jre-headless') do
        it { is_expected.to be_installed.with_version('11.0.1+13-3ubuntu3.18.10.1') }
      end

      describe package('wget') do
        it { is_expected.to be_installed.with_version('1.19.5-1ubuntu1') }
      end

      describe package('unzip') do
        it { is_expected.to be_installed.with_version('6.0-21ubuntu1') }
      end

      describe package('graphicsmagick') do
        it { is_expected.to be_installed.with_version('1.3.30+hg15796-1') }
      end

      describe package('curl') do
        it { is_expected.to be_installed.with_version('7.61.0-1ubuntu2.3') }
      end

      describe package('imagemagick') do
        it { is_expected.to be_installed.with_version('8:6.9.10.8+dfsg-1ubuntu2') }
      end

      describe package('ffmpeg') do
        it { is_expected.to be_installed.with_version('7:4.0.2-2') }
      end

      describe package('python') do
        it { is_expected.to be_installed.with_version('2.7.15-3') }
      end
    end
  end
end
