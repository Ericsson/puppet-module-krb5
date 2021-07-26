require 'spec_helper'
describe 'krb5', type: :class do
  # define os specific defaults
  platforms = {
    'RedHat' => {
      osfamily: 'RedHat',
      package:  ['krb5-libs', 'krb5-workstation'],
    },
    'Suse' => {
      osfamily: 'Suse',
      package:  ['krb5', 'krb5-client'],
    },
    'Debian' => {
      osfamily: 'Debian',
      package:  ['krb5-user'],
    },
    'Solaris 5.10' => {
      osfamily:      'Solaris',
      kernelrelease: '5.10',
      package:       ['SUNWkrbr', 'SUNWkrbu'],
    },
    'Solaris 5.11' => {
      osfamily:      'Solaris',
      kernelrelease: '5.11',
      package:       ['pkg:/service/security/kerberos-5'],
    },
  }

  krb5conf_default_content = <<-END.gsub(%r{^\s+\|}, '')
    |#Managed by puppet, any changes will be overwritten
    |
    |[logging]
    |default = FILE:/var/log/krb5libs.log
    |kdc = FILE:/var/log/krb5kdc.log
    |admin_server = FILE:/var/log/kadmind.log
  END

  describe 'with default values for parameters' do
    platforms.sort.each do |k, v|
      context "where OS is <#{k}>" do
        let :facts do
          {
            osfamily:      v[:osfamily],
            kernelrelease: v[:kernelrelease],
          }
        end

        it { is_expected.to contain_class('krb5') }

        v[:package].each do |package|
          it { is_expected.to contain_package(package).only_with_ensure('present') }
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

        if v[:osfamily] == 'Solaris'
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
  end

  context 'with all parameters set to valid values where OS is RedHat' do
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

    it {
      is_expected.to contain_file('krb5keytab_file').only_with(
        'ensure' => 'link',
        'path'   => '/etc/krb5.keytab',
        'target' => '/etc/opt/authenicationservice/key.keytab',
      )
    }
  end

  context 'Solaris specific params and functionalities' do
    let :facts do
      {
        osfamily:      'Solaris',
        kernelrelease: '5.11',
      }
    end

    context 'package_adminfile set to valid value' do
      let(:params) { { package_adminfile: '/sw/Solaris/Sparc/noask' } }

      it { is_expected.to contain_package('pkg:/service/security/kerberos-5').with_adminfile('/sw/Solaris/Sparc/noask') }
    end

    context 'package_provider set to valid value' do
      let(:params) { { package_provider: 'sun' } }

      it { is_expected.to contain_package('pkg:/service/security/kerberos-5').with_provider('sun') }
    end

    context 'package_source set to valid value' do
      let(:params) { { package_source: '/sw/Solaris/Sparc/krb/krb-x.xx-sol10-sparc' } }

      it { is_expected.to contain_package('pkg:/service/security/kerberos-5').with_source('/sw/Solaris/Sparc/krb/krb-x.xx-sol10-sparc') }
    end

    context 'with krb5conf_file parameter set to /test/ing' do
      let(:params) { { krb5conf_file: '/test/ing' } }

      it { is_expected.to contain_file('krb5conf').with_path('/test/ing') }
      it { is_expected.to contain_file('krb5link').with_target('/test/ing') }
    end
    context 'with krb5conf_owner parameter set to tester' do
      let(:params) { { krb5conf_owner: 'tester' } }

      it { is_expected.to contain_file('krb5conf').with_owner('tester') }
      it { is_expected.to contain_file('krb5directory').with_owner('tester') }
    end

    context 'with krb5conf_group parameter set to tester' do
      let(:params) { { krb5conf_group: 'tester' } }

      it { is_expected.to contain_file('krb5conf').with_group('tester') }
      it { is_expected.to contain_file('krb5directory').with_group('tester') }
    end
  end

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

  context 'with package parameter set to testing' do
    let(:params) { { package: ['testing'] } }

    it { is_expected.to contain_package('testing') }
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

    it {
      is_expected.to contain_file('krb5keytab_file').only_with(
        'ensure' => 'link',
        'path'   => '/etc/krb5.keytab',
        'target' => '/test/ing',
      )
    }

    it { is_expected.to contain_file('krb5keytab_file').with_target('/test/ing') }
  end

  context 'on unsupported Solaris with package set' do
    let :facts do
      {
        osfamily: 'Solaris',
        kernelrelease: '5.8',
      }
    end
    let(:params) { { package: ['solaris-58-krb5-package'] } }

    it { is_expected.to contain_package('solaris-58-krb5-package') }
  end

  context 'on unsupported osfamily with package set' do
    let(:facts) { { osfamily: 'WeirdOS' } }
    let(:params) { { package: ['weird-krb5-package'] } }

    it { is_expected.to contain_package('weird-krb5-package') }
  end

  context 'with default params on unsupported Solaris version' do
    let :facts do
      {
        osfamily: 'Solaris',
        kernelrelease: '5.8',
      }
    end

    it 'fails' do
      expect {
        is_expected.to contain_class('krb5')
      }.to raise_error(Puppet::Error,
                       %r{krb5 only supports default package names for Solaris 5\.10 and 5\.11\. Detected kernelrelease is <5\.8>\. Please specify package name with the \$package variable\.})
    end
  end

  context 'with default params on unsupported osfamily' do
    let(:facts) { { osfamily: 'WeirdOS' } }

    it 'fails' do
      expect {
        is_expected.to contain_class('krb5')
      }.to raise_error(Puppet::Error,
                       %r{krb5 only supports default package names for Debian, RedHat, Suse and Solaris\. Detected osfamily is <WeirdOS>\. Please specify package name with the \$package variable\.})
    end
  end

  context 'with krb5key_link_target set to <invalid>' do
    let(:params) { { krb5key_link_target: 'relactive/path/keytab' } }

    it 'fails' do
      expect {
        is_expected.to contain_class('krb5')
      }.to raise_error(Puppet::Error, %r{"relactive\/path\/keytab" is not an absolute path})
    end
  end

  describe 'variable data type and content validations' do
    validations = {
      'absolute_path' => {
        name:    ['default_keytab_name', 'package_adminfile', 'package_source ', 'krb5conf_file', 'krb5key_link_target'],
        valid:   ['/absolute/filepath', '/absolute/directory/'],
        invalid: ['../invalid', 3, 2.42, ['array'], { 'ha' => 'sh' }, false],
        message: 'is not an absolute path', # source: stdlib:validate_absolute_path
      },
      'array/string' => {
        name:    ['package'],
        valid:   ['string', ['array']],
        invalid: [{ 'ha' => 'sh' }, 3, 2.42, false],
        message: 'is not an array nor a string', # source: krb5:fail
      },
      'boolean / stringified boolean' => {
        name:    ['dns_lookup_realm', 'dns_lookup_kdc', 'forwardable', 'allow_weak_crypto', 'proxiable', 'rdns'],
        valid:   [true, false, 'true', 'false'],
        invalid: ['string', ['array'], { 'ha' => 'sh' }, 3, 2.42],
        message: 'is not a boolean', # source: krb5:fail
      },
      'hash' => {
        name:    ['realms', 'appdefaults', 'domain_realm'],
        valid:   [], # Valid hashes are too complex to test them easily here. They should have their own tests anyway.
        invalid: ['string', ['array'], 3, 2.42, false],
        message: 'is not a hash', # source: krb5:fail
      },
      'string' => {
        name:    ['logging_default', 'logging_kdc', 'logging_admin_server', 'logging_krb524d', 'default_ccache_name',
                  'default_tkt_enctypes', 'default_tgs_enctypes', 'krb5conf_owner', 'krb5conf_group'],
        valid:   ['string'],
        invalid: [['array'], { 'ha' => 'sh' }, 3, 2.42, false],
        message: 'is not a string', # source: krb5:fail
      },
      'string for domain name' => {
        name:    ['default_realm'],
        valid:   ['example.com', 'EXAMPLE.COM', 'va.lid', 'VA.LID'],
        invalid: ['under_score', 'sp ace', '-hypheninfront', 'spec!@|c#ars', ['array'], { 'ha' => 'sh' }, 2.42, false], # WTF: fixnum gets accepted
        message: 'is not a domain name', # source: krb5:fail
      },
      'string for file ensure' => {
        name:    ['krb5conf_ensure'],
        valid:   ['present', 'absent', 'file', 'directory', 'link'],
        invalid: ['string', ['array'], { 'ha' => 'sh' }, 3, 2.42, false],
        message: '(input needs to be a String|is not a valid value for file type ensure attribute)', # source: (stdlib5:validate_re|krb5:message)
      },
      'string for package provider' => {
        name:    ['package_provider'],
        valid:   ['sun', 'pkg'],
        invalid: ['string', ['array'], { 'ha' => 'sh' }, 3, 2.42, false],
        message: '(input needs to be a String|is not a valid value for package type provider attribute)', # source: (stdlib5:validate_re|krb5:message)
      },
      'string for service mode' => {
        name:    ['krb5conf_mode'],
        valid:   ['0777', '0644', '0242'],
        invalid: ['0999', 'string', ['array'], { 'ha' => 'sh' }, 3, 2.42, false],
        message: '(input needs to be a String|is not in four digit octal notation)', # source: (stdlib5:validate_re|krb5:message)
      },
      'string/integer' => {
        name:    ['ticket_lifetime'],
        valid:   ['string', 3],
        invalid: [['array'], { 'ha' => 'sh' }, 2.42, false], # WTF: is_string auto convert stringified integers to integers
        message: 'is not a string', # source: krb5:fail
      },
    }

    validations.sort.each do |type, var|
      var[:name].each do |var_name|
        var[:params] = {} if var[:params].nil?
        var[:valid].each do |valid|
          context "when #{var_name} (#{type}) is set to valid #{valid} (as #{valid.class})" do
            let(:params) { [var[:params], { "#{var_name}": valid, }].reduce(:merge) }

            it { is_expected.to compile }
          end
        end

        var[:invalid].each do |invalid|
          context "when #{var_name} (#{type}) is set to invalid #{invalid} (as #{invalid.class})" do
            let(:params) { [var[:params], { "#{var_name}": invalid, }].reduce(:merge) }

            it 'fail' do
              expect { is_expected.to contain_class(:subject) }.to raise_error(Puppet::Error, %r{#{var[:message]}})
            end
          end
        end
      end # var[:name].each
    end # validations.sort.each
  end # describe 'variable type and content validations'
end
