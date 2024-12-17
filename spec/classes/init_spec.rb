require 'spec_helper'

describe 'gdm' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_simplib__install('gdm packages') }
        it { is_expected.to contain_notify('Additional Puppet Run Needed for gdm') }
        it { is_expected.to contain_class('gdm::service') }

        context 'GDM = 3.0.0' do
          let(:facts) { os_facts.merge({ runlevel: '5', gdm_version: '3.14.2' }) }

          context 'default parameters' do
            it { is_expected.to compile.with_all_deps }
            it { is_expected.to create_class('gdm') }
            it { is_expected.to contain_simplib__install('gdm packages').that_notifies('Class[gdm::service]') }
            it { is_expected.to contain_simplib__install('gdm packages').that_comes_before('Class[gdm::config]') }
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
            it { is_expected.to contain_svckill__ignore('gdm') }
            it { is_expected.to contain_svckill__ignore('display-manager') }
            it { is_expected.to contain_svckill__ignore('accounts-daemon') }
            it { is_expected.to contain_svckill__ignore('upower') }
            it { is_expected.to contain_svckill__ignore('rtkit-daemon') }

            it { is_expected.to create_dconf__settings('GDM Dconf Settings') }
            it {
              dconf_resource = catalogue.resource('Dconf::Settings[GDM Dconf Settings]')
              expect(dconf_resource[:settings_hash]['org/gnome/login-screen']['banner-message-text']['value']).to match(%r{ATTENTION})
              expect(dconf_resource[:settings_hash]['org/gnome/login-screen']['banner-message-enable']['value']).to be true
            }
            it {
              is_expected.to create_gdm__set('GDM [chooser] Multicast:false').with(
                {
                  section: 'chooser',
                  key: 'Multicast',
                  value: 'false'
                },
              )
            }
            it { is_expected.to create_gdm__set('GDM [daemon] TimedLoginEnable:false') }
            it { is_expected.to create_gdm__set('GDM [daemon] AutomaticLoginEnable:false') }
            it { is_expected.to create_gdm__set('GDM [greeter] IncludeAll:false') }
            it { is_expected.to create_gdm__set('GDM [security] DisallowTCP:true') }
            it { is_expected.to create_gdm__set('GDM [xdmcp] Enable:false') }
          end

          context 'modifying the banner' do
            context 'disable' do
              let(:params) { { banner: false } }

              it { is_expected.to compile.with_all_deps }
              it { is_expected.to create_dconf__settings('GDM Dconf Settings') }
              it {
                dconf_resource = catalogue.resource('Dconf::Settings[GDM Dconf Settings]')
                expect(dconf_resource[:settings_hash]['org/gnome/login-screen']['banner-message-enable']['value']).to be false
              }
            end

            context 'set new content' do
              let(:params) { { banner_content: 'I like banners' } }
              let(:to_match) { "'I like banners'" }
              let(:dconf_resource) { catalogue.resource('Dconf::Settings[GDM Dconf Settings]') }

              it { is_expected.to compile.with_all_deps }
              it { is_expected.to create_dconf__settings('GDM Dconf Settings') }
              it {
                expect(dconf_resource[:settings_hash]['org/gnome/login-screen']['banner-message-enable']['value']).to be true
                expect(dconf_resource[:settings_hash]['org/gnome/login-screen']['banner-message-text']['value']).to eq(to_match)
              }

              context 'with pre-added quotes' do
                let(:params) { { banner_content: 'I like banners' } }

                it { is_expected.to compile.with_all_deps }
                it {
                  expect(dconf_resource[:settings_hash]['org/gnome/login-screen']['banner-message-text']['value']).to eq(to_match)
                }
              end
            end

            context 'change simp_banner selection' do
              let(:params) { { simp_banner: 'us/department_of_commerce' } }

              it { is_expected.to compile.with_all_deps }
              it { is_expected.to create_dconf__settings('GDM Dconf Settings') }
              it {
                dconf_resource = catalogue.resource('Dconf::Settings[GDM Dconf Settings]')
                expect(dconf_resource[:settings_hash]['org/gnome/login-screen']['banner-message-enable']['value']).to be true
                expect(dconf_resource[:settings_hash]['org/gnome/login-screen']['banner-message-text']['value']).to match(%r{Department of Commerce}i)
              }
            end
          end
        end

        context 'with hidepid on' do
          let(:facts) do
            os_facts.merge(
              {
                runlevel: '5',
                gdm_version: '3.14.2',
                simplib__mountpoints: {
                  '/proc' => {
                    'options_hash' => {
                      '_gid__group' => 'proc_access',
                      'gid'         => 231,
                      'hidepid'     => 2
                    }
                  }
                }
              },
            )
          end

          it {
            is_expected.to create_systemd__dropin_file('gdm_hidepid.conf').with({
                                                                                  unit: 'systemd-logind.service',
            content: %r{SupplementaryGroups=231}
                                                                                })
          }
        end

        context 'with old version on GDM' do
          let(:facts) do
            os_facts.merge(
              {
                runlevel: '5',
                gdm_version: '2.1'
              },
            )
          end

          it { is_expected.to raise_error(Puppet::ParseError) }
        end

        context 'with pam enabled' do
          let(:params) { { pam: true } }

          it {
            is_expected.to create_pam__access__rule('allow_local_display_manager').with({
                                                                                          permission: '+',
            users: ['gdm'],
            origins: ['LOCAL']
                                                                                        })
          }
        end
      end
    end
  end
end
