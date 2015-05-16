require 'spec_helper'

describe 'xwindows::gdm' do

  base_facts = {
    :gdm_version => '2'
  }
  let(:facts){base_facts}

  let(:params) { {:include_sec => true} }

  it { should create_class('xwindows::gdm') }
  it { should contain_class('xwindows::gdm::sec') }
  it { should contain_package('gdm') }
  it { should contain_file('/etc/sysconfig/desktop') }
  it { should contain_exec('restart_gdm') }

end
