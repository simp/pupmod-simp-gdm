require 'spec_helper'

describe 'gdm' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('gdm::install') }
        it { is_expected.to contain_notify('Additional Puppet Run Needed for gdm') }
        it { is_expected.to_not contain_class('gdm::service') }

        context 'EL7 with GDM = 3.0.0' do
          if os_facts[:operatingsystemmajrelease].to_s >= '7'
            context 'default parameters' do
              let(:facts){ os_facts.merge({:runlevel => '5', :gdm_version => '3.14.2'}) }
              it { is_expected.to compile.with_all_deps }
              it { is_expected.to contain_class('gdm::install').that_notifies('Class[gdm::service]') }
              it { is_expected.to contain_class('gdm::service').that_comes_before('Class[gdm]') }
              it { is_expected.to create_class('gdm') }
              @package = [
                'gdm', 'xorg-x11-drivers', 'xorg-x11-xinit', 'xorg-x11-utils', 'xorg-x11-docs',
                'dejavu-sans-fonts', 'dejavu-sans-mono-fonts', 'dejavu-serif-fonts',
                'bitmap-fixed-fonts', 'bitmap-lucida-typewriter-fonts',
                'liberation-mono-fonts', 'liberation-sans-fonts', 'liberation-serif-fonts',
                'xorg-x11-fonts-100dpi', 'xorg-x11-fonts-75dpi', 'xorg-x11-fonts-ISO8859-1-100dpi',
                'xorg-x11-fonts-ISO8859-1-75dpi', 'xorg-x11-fonts-Type1', 'xorg-x11-fonts-misc',
                'xorg-x11-server-Xorg'
              ]
              @package.each do |pkg|
                it { is_expected.to contain_package(pkg) }
              end
              it { is_expected.to contain_class ('gdm::sec') }
              it { is_expected.to_not contain_file('/etc/sysconfig/desktop') }
              it { is_expected.to_not contain_auditd__rule ( 'system_gdm' ) }
              it { is_expected.to_not contain_exec( 'restart_gdm' ) }
              it { is_expected.to contain_service('gdm') }
              it { is_expected.to contain_service('accounts-daemon') }
            end
          end
        end
        context 'EL6 with GDM < 3.0.0' do
          if os_facts[:operatingsystemmajrelease].to_s < '7'
            context 'default parameters' do
              let(:facts){ os_facts.merge({:runlevel => '5', :gdm_version => '2.0.0'}) }
              it { is_expected.to compile.with_all_deps }
              it { is_expected.to contain_class('gdm::install').that_notifies('Class[gdm::service]') }
              it { is_expected.to contain_class('gdm::service').that_comes_before('Class[gdm]') }
              it { is_expected.to create_class('gdm') }

              @package = [
                'gdm', 'xorg-x11-apps','xorg-x11-drivers', 'xorg-x11-xinit', 'xorg-x11-twm', 'xterm',
                'xorg-x11-fonts-100dpi', 'xorg-x11-fonts-75dpi', 'xorg-x11-fonts-ISO8859-1-100dpi',
                'xorg-x11-fonts-ISO8859-1-75dpi', 'xorg-x11-fonts-Type1', 'xorg-x11-fonts-misc',
                'xorg-x11-server-Xorg', 'dejavu-lgc-sans-fonts', 'dejavu-lgc-sans-mono-fonts',
                'dejavu-lgc-serif-fonts', 'dejavu-sans-fonts', 'dejavu-sans-mono-fonts',
                'dejavu-serif-fonts', 'bitmap-console-fonts', 'bitmap-fangsongti-fonts',
                'bitmap-fixed-fonts', 'bitmap-fonts-compat', 'bitmap-lucida-typewriter-fonts',
                'bitmap-miscfixed-fonts', 'liberation-mono-fonts', 'liberation-sans-fonts',
                'liberation-serif-fonts'
              ]
              @package.each do |pkg|
                it { is_expected.to contain_package(pkg) }
              end
              it { is_expected.to contain_class ('gdm::sec') }
              it { is_expected.to contain_file('/etc/sysconfig/desktop') }
              it { is_expected.to_not contain_auditd__rule ( 'system_gdm' ) }
              it { is_expected.to contain_exec( 'restart_gdm' ) }
              it { is_expected.to_not contain_service('gdm') }
              it { is_expected.to_not contain_service('accounts-daemon') }
            end
          end
        end
      end
    end
  end
end
