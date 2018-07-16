require 'spec_helper_acceptance'

test_name 'simp::gdm with gnome'

describe 'simp::gdm with gnome' do
  let(:manifest) {
    <<-EOS
      include 'gnome'
    EOS
  }

  hosts.each do |host|
    context "on #{host}" do
      it 'should work no errors' do
        apply_manifest_on(host, manifest, :catch_failures => true)
      end

      # After this, you can try the GUI and see what happens
      it 'should have GNOME installed' do
        host.check_for_command('gnome-session').should be true
      end
    end
  end
end
