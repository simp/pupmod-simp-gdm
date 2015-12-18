require 'spec_helper'

describe 'xwindows::gdm' do

  base_facts = {
    :gdm_version => '2'
  }
  let(:facts){base_facts}

  let(:params) { {:include_sec => true} }

  it { is_expected.to create_class('xwindows::gdm') }
  it { is_expected.to contain_class('xwindows::gdm::sec') }
  it { is_expected.to contain_package('gdm') }
  it { is_expected.to contain_file('/etc/sysconfig/desktop') }
  it { is_expected.to contain_exec('restart_gdm') }

end
