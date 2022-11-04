require 'spec_helper'
describe 'krb5', type: :class do
  # The following tests are OS independent, so we only test one supported OS
  redhat = {
    supported_os: [
      {
        'operatingsystem'        => 'RedHat',
        'operatingsystemrelease' => ['7'],
      },
    ],
  }

  on_supported_os(redhat).each do |_os, os_facts|
    describe 'with all parameters set to valid values where OS is RedHat' do
      let(:facts) { os_facts }
      let :params do
        {
          logging_default:      'FILE:/tmp/log1',
          logging_kdc:          'FILE:/tmp/log2',
          logging_admin_server: 'FILE:/tmp/log3',
          logging_krb524d:      'FILE:/tmp/log4',
          default_realm:        'EXAMPLE.COM',
          dns_lookup_realm:     false,
          dns_lookup_kdc:       false,
          ticket_lifetime:      '24h',
          default_ccache_name:  'FILE:/tmp/krb5cc_%{uid}',
          default_keytab_name:  '/etc/opt/quest/vas/host.keytab',
          forwardable:          true,
          allow_weak_crypto:    false,
          proxiable:            true,
          realms: {
            'EXAMPLE.COM'         => {
              'default_domain'    => 'example.com',
              'kdc'               => ['kdc1.example.com:88', 'kdc2.example.com:88'],
              'admin_server'      => ['kdc1.example.com:749', 'kdc2.example.com:749'],
            },
            'ANOTHER.EXAMPLE.COM' => {
              'default_domain'    => 'another.example.com',
              'kdc'               => 'kdc1.another.example.com:88',
              'admin_server'      => 'kdc1.another.example.com:749',
            },
          },
          appdefaults: {
            'pam'                 => {
              'debug'             => 'false',
              'ticket_lifetime'   => '36000',
              'renew_lifetime'    => '36000',
              'forwardable'       => 'true',
              'krb4_convert'      => 'false',
            },
          },
          domain_realm: {
            'example.com' => 'EXAMPLE.COM',
          },
          rdns:                 false,
          default_tkt_enctypes: 'aes256-cts',
          default_tgs_enctypes: 'aes128-cts',
          package:              ['krb5-package-testing'],
          krb5conf_file:        '/etc/testing/krb5.conf',
          krb5conf_ensure:      'file',
          krb5conf_owner:       'tester_owner',
          krb5conf_group:       'tester_group',
          krb5conf_mode:        '0242',
          krb5key_link_target:  '/etc/opt/authenicationservice/key.keytab',
        }
      end

      it { is_expected.to contain_package('krb5-package-testing') }

      it do
        is_expected.to contain_file('krb5conf').only_with(
          'ensure'  => 'file',
          'path'    => '/etc/testing/krb5.conf',
          'owner'   => 'tester_owner',
          'group'   => 'tester_group',
          'mode'    => '0242',
          'content' => File.read(fixtures('krb5.conf.allset')),
        )
      end

      it { is_expected.not_to contain_file('krb5directory') }
      it { is_expected.not_to contain_file('krb5link') }

      it do
        is_expected.to contain_file('krb5keytab_file').only_with(
          'ensure' => 'link',
          'path'   => '/etc/krb5.keytab',
          'target' => '/etc/opt/authenicationservice/key.keytab',
        )
      end
    end
  end

  context 'on unsupported Solaris with package set' do
    let :facts do
      {
        os: {
          family: 'Solaris',
        },
        kernelrelease: '5.8',
      }
    end
    let(:params) { { package: ['solaris-58-krb5-package'] } }

    it { is_expected.to contain_package('solaris-58-krb5-package') }
    it { is_expected.to contain_file('krb5directory') } # only needed for 100% resource coverage
    it { is_expected.to contain_file('krb5link') }      # only needed for 100% resource coverage
  end

  context 'on unsupported osfamily with package set' do
    let(:facts) { { os: { family: 'WeirdOS' } } }
    let(:params) { { package: ['weird-krb5-package'] } }

    it { is_expected.to contain_package('weird-krb5-package') }
  end
end
