require 'spec_helper'
describe 'krb5', type: :class do
  krb5conf_default_content = <<-END.gsub(%r{^\s+\|}, '')
    |#Managed by puppet, any changes will be overwritten
    |
    |[logging]
    |default = FILE:/var/log/krb5libs.log
    |kdc = FILE:/var/log/krb5kdc.log
    |admin_server = FILE:/var/log/kadmind.log
  END

  on_supported_os.sort.each do |os, os_facts|
    # define os specific defaults
    case os_facts[:os]['family']
    when 'RedHat'
      package = ['krb5-libs', 'krb5-workstation']
    when 'Suse'
      package = ['krb5', 'krb5-client']
    when 'Debian'
      package = ['krb5-user']
    when 'Solaris'
      package = if os_facts[:kernelrelease] == '5.10'
                  ['SUNWkrbr', 'SUNWkrbu']
                else
                  ['pkg:/service/security/kerberos-5']
                end
    end

    describe "on #{os} with default values for parameters" do
      let(:facts) { os_facts }

      it { is_expected.to contain_class('krb5') }

      package.each do |pkg|
        it { is_expected.to contain_package(pkg).only_with_ensure('present') }
      end

      it do
        is_expected.to contain_file('krb5conf').only_with(
          'ensure'  => 'present',
          'path'    => '/etc/krb5.conf',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'content' => krb5conf_default_content,
        )
      end

      if os_facts[:os]['family'] == 'Solaris'
        it do
          is_expected.to contain_file('krb5directory').only_with(
            'ensure' => 'directory',
            'path'   => '/etc/krb5',
            'owner'  => 'root',
            'group'  => 'root',
          )
        end

        it do
          is_expected.to contain_file('krb5link').only_with(
            'ensure'  => 'link',
            'path'    => '/etc/krb5/krb5.conf',
            'target'  => '/etc/krb5.conf',
            'require' => 'File[krb5directory]',
          )
        end
      else
        it { is_expected.not_to contain_file('krb5directory') }
        it { is_expected.not_to contain_file('krb5link') }
      end
      it { is_expected.not_to contain_file('krb5keytab_file') }
    end
  end

  describe 'on supported OS RedHat' do
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
      let(:facts) { os_facts }

      context 'with logging defaults disabled (logging_default, logging_kdc, and logging_admin_server parameters are unset (empty strings))' do
        let :params do
          {
            logging_default:      '',
            logging_kdc:          '',
            logging_admin_server: '',
          }
        end

        it do
          is_expected.to contain_file('krb5conf').with_content(
            %r{^#Managed by puppet, any changes will be overwritten\n$},
          )
        end
      end

      context 'with logging_default parameter only set (logging_kdc and logging_admin_server are unset (empty strings))' do
        let :params do
          {
            logging_default:      'FILE:/var/logging/default_only.log',
            logging_kdc:          '',
            logging_admin_server: '',
          }
        end

        it do
          is_expected.to contain_file('krb5conf').with_content(
            %r{^#Managed by puppet, any changes will be overwritten$\n\n\[logging\]\ndefault = FILE:\/var\/logging\/default_only.log\n$},
          )
        end
      end

      context 'with logging_kdc parameter only set (logging_default and logging_admin_server are unset (empty strings))' do
        let :params do
          {
            logging_default:      '',
            logging_kdc:          'FILE:/var/logging/kdc_only.log',
            logging_admin_server: '',
          }
        end

        it do
          is_expected.to contain_file('krb5conf').with_content(
            %r{^#Managed by puppet, any changes will be overwritten$\n\n\[logging\]\nkdc = FILE:\/var\/logging\/kdc_only.log\n$},
          )
        end
      end

      context 'with logging_admin_server parameter only set (logging_default and logging_kdc are unset (empty strings))' do
        let :params do
          {
            logging_default:      '',
            logging_kdc:          '',
            logging_admin_server: 'FILE:/var/logging/admin_server_only.log',
          }
        end

        it do
          is_expected.to contain_file('krb5conf').with_content(
            %r{^#Managed by puppet, any changes will be overwritten$\n\n\[logging\]\nadmin_server = FILE:\/var\/logging\/admin_server_only.log\n$},
          )
        end
      end

      context 'with logging_krb524d parameter only set (logging_default, logging_kdc, and logging_admin_server are unset (empty strings))' do
        let :params do
          {
            logging_default:      '',
            logging_kdc:          '',
            logging_admin_server: '',
            logging_krb524d:      'FILE:/var/logging/krb524d_only.log',
          }
        end

        it do
          is_expected.to contain_file('krb5conf').with_content(
            %r{^#Managed by puppet, any changes will be overwritten$\n\n\[logging\]\nkrb524d = FILE:\/var\/logging\/krb524d_only.log\n$},
          )
        end
      end

      context 'with default_realm parameter set to TEST.ING' do
        let(:params) { { default_realm: 'TEST.ING' } }

        it { is_expected.to contain_file('krb5conf').with_content(krb5conf_default_content + "\n\[libdefaults\]\ndefault_realm = TEST.ING\n") }
      end

      context 'with dns_lookup_realm parameter set to true' do
        let(:params) { { dns_lookup_realm: true } }

        it { is_expected.to contain_file('krb5conf').with_content(krb5conf_default_content + "\n\[libdefaults\]\ndns_lookup_realm = true\n") }
      end

      context 'with dns_lookup_kdc parameter set to true' do
        let(:params) { { dns_lookup_kdc: true } }

        it { is_expected.to contain_file('krb5conf').with_content(krb5conf_default_content + "\n\[libdefaults\]\ndns_lookup_kdc = true\n") }
      end

      context 'with ticket_lifetime parameter set to 242h' do
        let(:params) { { ticket_lifetime: '242h' } }

        it { is_expected.to contain_file('krb5conf').with_content(krb5conf_default_content + "\n\[libdefaults\]\nticket_lifetime = 242h\n") }
      end

      context 'with ticket_lifetime parameter set to 24000' do
        let(:params) { { ticket_lifetime: '24000' } }

        it { is_expected.to contain_file('krb5conf').with_content(krb5conf_default_content + "\n\[libdefaults\]\nticket_lifetime = 24000\n") }
      end

      context 'with default_ccache_name parameter set to FILE:/test/ing_%{uid}' do
        let(:params) { { default_ccache_name: 'FILE:/test/ing_%{uid}' } }

        it { is_expected.to contain_file('krb5conf').with_content(krb5conf_default_content + "\n\[libdefaults\]\ndefault_ccache_name = FILE:\/test\/ing_%{uid}\n") }
      end

      context 'with default_keytab_name parameter set to /test/ing.keytab' do
        let(:params) { { default_keytab_name: '/test/ing.keytab' } }

        it { is_expected.to contain_file('krb5conf').with_content(krb5conf_default_content + "\n\[libdefaults\]\ndefault_keytab_name = /test/ing.keytab\n") }
      end

      context 'with forwardable parameter set to false' do
        let(:params) { { forwardable: false } }

        it { is_expected.to contain_file('krb5conf').with_content(krb5conf_default_content + "\n\[libdefaults\]\nforwardable = false\n") }
      end

      context 'with allow_weak_crypto parameter set to true' do
        let(:params) { { allow_weak_crypto: true } }

        it { is_expected.to contain_file('krb5conf').with_content(krb5conf_default_content + "\n\[libdefaults\]\nallow_weak_crypto = true\n") }
      end

      context 'with proxiable parameter set to false' do
        let(:params) { { proxiable: false } }

        it { is_expected.to contain_file('krb5conf').with_content(krb5conf_default_content + "\n\[libdefaults\]\nproxiable = false\n") }
      end

      context 'with realms parameter set to a valid hash and order is retained in the output' do
        let :params do
          {
            realms: {
              'TEST2.ING' => {
                'default_domain' => 'test2.ing',
                'kdc'            => ['kdc1.test2.ing:242', 'kdc2.test2.ing:242'],
                'admin_server'   => ['kdc2.test2.ing:23', 'kdc1.test2.ing:23'],
              },
              'TEST1.ING' => {
                'kdc'            => ['kdc2.test1.ing:242', 'kdc1.test1.ing:242'],
                'admin_server'   => ['kdc1.test1.ing:23', 'kdc2.test1.ing:23'],
                'default_domain' => 'test1.ing',
              },
            },
          }
        end

        hash_content = <<-END.gsub(%r{^\s+\|}, '')
          |
          |[realms]
          |TEST2.ING = {
          |  default_domain = test2.ing
          |  kdc = kdc1.test2.ing:242
          |  kdc = kdc2.test2.ing:242
          |  admin_server = kdc2.test2.ing:23
          |  admin_server = kdc1.test2.ing:23
          |}
          |TEST1.ING = {
          |  kdc = kdc2.test1.ing:242
          |  kdc = kdc1.test1.ing:242
          |  admin_server = kdc1.test1.ing:23
          |  admin_server = kdc2.test1.ing:23
          |  default_domain = test1.ing
          |}
        END

        it { is_expected.to contain_file('krb5conf').with_content(krb5conf_default_content + hash_content) }
      end

      context 'with appdefaults parameter set to a valid hash and order is retained in the output' do
        let :params do
          {
            appdefaults: {
              'test'              => {
                'ticket_lifetime' => '36000',
                'forwardable'     => 'true',
                'renew_lifetime'  => '36000',
                'krb4_convert'    => 'false',
                'debug'           => 'false',
              },
            },
          }
        end

        hash_content = <<-END.gsub(%r{^\s+\|}, '')
          |
          |[appdefaults]
          |test = {
          |         ticket_lifetime = 36000
          |         forwardable = true
          |         renew_lifetime = 36000
          |         krb4_convert = false
          |         debug = false
          |}
        END

        it { is_expected.to contain_file('krb5conf').with_content(krb5conf_default_content + hash_content) }
      end

      context 'with domain_realm parameter set to a valid hash and order is retained in the output' do
        let :params do
          {
            domain_realm: {
              'test2.ing' => 'TEST2.ING',
              'test1.ing' => 'TEST1.ING',
            },
          }
        end

        hash_content = <<-END.gsub(%r{^\s+\|}, '')
          |
          |[domain_realm]
          |.test2.ing = TEST2.ING
          |test2.ing = TEST2.ING
          |.test1.ing = TEST1.ING
          |test1.ing = TEST1.ING
        END

        it { is_expected.to contain_file('krb5conf').with_content(krb5conf_default_content + hash_content) }
      end

      context 'with rdns parameter set to true' do
        let(:params) { { rdns: true } }

        it { is_expected.to contain_file('krb5conf').with_content(krb5conf_default_content + "\n\[libdefaults\]\nrdns = true\n") }
      end

      context 'with default_tkt_enctypes parameter set to aes242-cts' do
        let(:params) { { default_tkt_enctypes: 'aes242-cts' } }

        it { is_expected.to contain_file('krb5conf').with_content(krb5conf_default_content + "\n\[libdefaults\]\ndefault_tkt_enctypes = aes242-cts\n") }
      end

      context 'with default_tgs_enctypes parameter set to aes242-cts' do
        let(:params) { { default_tgs_enctypes: 'aes242-cts' } }

        it { is_expected.to contain_file('krb5conf').with_content(krb5conf_default_content + "\n\[libdefaults\]\ndefault_tgs_enctypes = aes242-cts\n") }
      end

      context 'with package parameter set to testing' do
        let(:params) { { package: ['testing'] } }

        it { is_expected.to contain_package('testing') }
      end

      context 'package_adminfile set to valid value' do
        let(:params) { { package_adminfile: '/sw/Solaris/Sparc/noask' } }

        it { is_expected.to contain_package('krb5-workstation').with_adminfile('/sw/Solaris/Sparc/noask') }
      end

      context 'package_provider set to valid value' do
        let(:params) { { package_provider: 'sun' } }

        it { is_expected.to contain_package('krb5-workstation').with_provider('sun') }
      end

      context 'package_source set to valid value' do
        let(:params) { { package_source: '/sw/Solaris/Sparc/krb/krb-x.xx-sol10-sparc' } }

        it { is_expected.to contain_package('krb5-workstation').with_source('/sw/Solaris/Sparc/krb/krb-x.xx-sol10-sparc') }
      end

      context 'with krb5conf_file parameter set to /test/ing' do
        let(:params) { { krb5conf_file: '/test/ing' } }

        it { is_expected.to contain_file('krb5conf').with_path('/test/ing') }
      end

      context 'with krb5conf_ensure parameter set to file' do
        let(:params) { { krb5conf_ensure: 'file' } }

        it { is_expected.to contain_file('krb5conf').with_ensure('file') }
      end

      context 'with krb5conf_owner parameter set to tester' do
        let(:params) { { krb5conf_owner: 'tester' } }

        it { is_expected.to contain_file('krb5conf').with_owner('tester') }
      end

      context 'with krb5conf_group parameter set to tester' do
        let(:params) { { krb5conf_group: 'tester' } }

        it { is_expected.to contain_file('krb5conf').with_group('tester') }
      end

      context 'with krb5conf_mode parameter set to 0242' do
        let(:params) { { krb5conf_mode: '0242' } }

        it { is_expected.to contain_file('krb5conf').with_mode('0242') }
      end

      context 'with krb5key_link_target parameter set to /test/ing' do
        let(:params) { { krb5key_link_target: '/test/ing' } }

        it do
          is_expected.to contain_file('krb5keytab_file').only_with(
            'ensure' => 'link',
            'path'   => '/etc/krb5.keytab',
            'target' => '/test/ing',
          )
        end

        it { is_expected.to contain_file('krb5keytab_file').with_target('/test/ing') }
      end
    end
  end
end
