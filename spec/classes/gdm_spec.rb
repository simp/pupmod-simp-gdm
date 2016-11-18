require 'spec_helper'

describe 'xwindows::gdm' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts){ os_facts.merge({:gdm_version => '2'}) }

        let(:params) { {:include_sec => true} }

        it { is_expected.to create_class('xwindows::gdm') }
        it { is_expected.to contain_class('xwindows::gdm::sec') }
        it { is_expected.to contain_package('gdm') }
        it { is_expected.to contain_file('/etc/sysconfig/desktop') }
        it { is_expected.to contain_exec('restart_gdm') }
      end
    end
  end
end
