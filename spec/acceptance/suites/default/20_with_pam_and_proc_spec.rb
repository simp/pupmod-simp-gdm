require 'spec_helper_acceptance'

test_name 'simp::gdm with gnome and pam and hidepid'

describe 'simp::gdm with gnome and pam and hidepid' do
let(:manifest) {
  <<-EOS
    include 'pam'
    include 'simp::mountpoints::proc'
    include 'gdm'
    include 'gnome'
  EOS
}
let(:hieradata){ <<-EOS
simp_options::pam: true
EOS
}

  hosts.each do |host|
    context "on #{host}" do
      it 'should set_up pam through hiera' do
         set_hieradata_on(host, hieradata)
      end

      it 'should work no errors' do
        apply_manifest_on(host, manifest, :catch_failures => true)
      end

      # After this, you can try the GUI and see what happens
      it 'should have GDM started' do
        result = on(host, "systemctl status gdm.service")
        expect(result.stdout).to match(/Active: active \(running\)/)
      end
    end
  end

end
