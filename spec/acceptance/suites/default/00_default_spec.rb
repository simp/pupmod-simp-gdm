require 'spec_helper_acceptance'

test_name 'simp::gdm class'

describe 'simp::gdm class' do
  let(:manifest) {
    <<-EOS
      include 'gdm'

      runlevel { 'graphical': }
    EOS
  }

  hosts.each do |host|
    context "on #{host}" do
      it 'should work but may have errors' do
        apply_manifest_on(host, manifest, :allow_all_exit_codes => true)
      end

      it 'should require a reboot and relabel' do
        # This is needed to get the SELinux contexts worked out properly
        on(host, 'touch /.autorelabel')
        host.reboot
      end

      it 'should require another run' do
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
        retry_on(host, 'pgrep -u gdm')
      end
    end
  end
end
