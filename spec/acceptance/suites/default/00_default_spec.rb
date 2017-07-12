require 'spec_helper_acceptance'

#TODO move to Simp::BeakerHelpers
require 'timeout'

# Wait up to max_wait_seconds for a command on a host to succeed or fail the test
# @param [String] host Name of test server on which the command will be executed
# @param [String] command Command to be executed
# @param [Float]  max_wait_seconds Maximum number of seconds to wait for the
#                 message to be found in the log before failing
# @param [Float]  interval_sec Interval in seconds between log checks
def wait_for_command_success(
  host,
  command,
  max_wait_seconds = (ENV['SIMPTEST_WAIT_FOR_COMMAND_MAX'] ? ENV['SIMPTEST_WAIT_FOR_COMMAND_MAX'].to_f : 60.0),
  interval_sec = (ENV['SIMPTEST_COMMAND_CHECK_INTERVAL'] ? ENV['SIMPTEST_COMMAND_CHECK_INTERVAL'].to_f : 1.0)
)
  result = nil
  Timeout::timeout(max_wait_seconds) do
    while true
      result = on host, command, :accept_all_exit_codes => true
      return if result.exit_code == 0
      sleep(interval_sec)
    end
  end
rescue Timeout::Error => e
  error_msg = "Failed to successfully execute '#{command}' on #{host} within #{max_wait_seconds} seconds:\n"
  error_msg += "\texit_code = #{result.exit_code}\n"
  error_msg += "\tstdout = \"#{result.stdout}\"\n" unless result.stdout.nil? or result.stdout.strip.empty?
  error_msg += "\tstderr = \"#{result.stderr}\"" unless result.stderr.nil? or result.stderr.strip.empty?
  fail error_msg
end

test_name 'simp::gdm class'

describe 'simp::gdm class' do
  let(:manifest) {
    <<-EOS
      include 'gdm'

      runlevel { '5': persist => true }
    EOS
  }

  context 'on the hosts' do
    hosts.each do |host|
      it 'should work with no errors' do
        apply_manifest_on(host, manifest, :catch_failures => true)
      end

      it 'should require two runs' do
        # This needs two runs due to the GDM version fact
        apply_manifest_on(host, manifest, :catch_failures => true)
      end

      it 'should be idempotent once stable' do
        apply_manifest_on(host, manifest, :catch_changes => true)
      end

      it 'should be running GDM' do
        on(host, 'pgrep -u gdm')
      end

      it 'should be running GDM after reboot' do
        host.reboot
        wait_for_command_success(host, 'pgrep -u gdm')
      end
    end
  end
end
