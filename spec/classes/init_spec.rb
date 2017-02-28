require 'spec_helper'

describe 'krb5' do

  context 'with defaults for all parameters on RedHat' do
    let(:facts) do { :osfamily => 'RedHat', } end
    it { should contain_class('krb5') }
    it { should contain_package('krb5-libs') }
    it { should contain_package('krb5-workstation') }
    it { should contain_file('krb5conf').with({
      'path'   => '/etc/krb5.conf',
      'ensure' => 'present',
      'owner'  => 'root',
      'group'  => 'root',
      'mode'   => '0644',
    }) }

    krb5conf_fixture = File.read(fixtures("krb5.conf.defaults"))
    it { should contain_file('krb5conf').with_content(krb5conf_fixture) }
  end

  context 'with defaults for all parameters on Suse' do
    let(:facts) do { :osfamily => 'Suse', } end
    it { should contain_class('krb5') }
    it { should contain_package('krb5') }
    it { should contain_package('krb5-client') }
    it { should contain_file('krb5conf').with({
      'path'   => '/etc/krb5.conf',
      'ensure' => 'present',
      'owner'  => 'root',
      'group'  => 'root',
      'mode'   => '0644',
    }) }

    krb5conf_fixture = File.read(fixtures("krb5.conf.defaults"))
    it { should contain_file('krb5conf').with_content(krb5conf_fixture) }
  end

  context 'with default params on osfamily Solaris kernelrelease 5.8' do
    let :facts do
      {
        :osfamily      => 'Solaris',
        :kernelrelease => '5.8',
      }
    end
    it 'should fail' do
      expect {
        should contain_class('krb5')
}.to raise_error(Puppet::Error,/Default packages defined for only SunOS 5\.10 and 5\.11\. Please specify the krb5 packages in hiera/)
    end
  end

  context 'with default params on osfamily Solaris kernelrelease 5.11' do
    let :facts do
      {
        :osfamily      => 'Solaris',
        :kernelrelease => '5.11',
      }
    end
    let(:params) do
      {
        :package_provider  => 'pkg',
      }
    end
    it { should contain_class('krb5') }
    it {
      should contain_package('pkg:/service/security/kerberos-5').with({
        'provider'  => 'pkg',
      })
    }
    it { should contain_file('krb5conf').with({
      'path'   => '/etc/krb5.conf',
      'ensure' => 'present',
      'owner'  => 'root',
      'group'  => 'root',
      'mode'   => '0644',
    }) }
    it { should contain_file('krb5directory').with({
      'path'   => '/etc/krb5',
      'ensure' => 'directory',
      'owner'  => 'root',
      'group'  => 'root',
    }) }
    it { should contain_file('krb5link').with({
      'path'   => '/etc/krb5/krb5.conf',
      'ensure' => 'link',
      'target' => '/etc/krb5.conf',
    }) }
    krb5conf_fixture = File.read(fixtures("krb5.conf.defaults"))
    it { should contain_file('krb5conf').with_content(krb5conf_fixture) }
  end

  context 'with default params on osfamily Solaris kernelrelease 5.10' do
    let :facts do
      {
        :osfamily      => 'Solaris',
        :kernelrelease => '5.10',
      }
    end
    let(:params) do
      { :package_adminfile => '/sw/Solaris/Sparc/noask',
        :package_provider  => 'sun',
        :package_source    => '/sw/Solaris/Sparc/krb/krb-x.xx-sol10-sparc',
      }
    end
    it { should contain_class('krb5') }
    it {
      should contain_package('SUNWkrbr').with({
        'adminfile' => '/sw/Solaris/Sparc/noask',
        'provider'  => 'sun',
        'source'    => '/sw/Solaris/Sparc/krb/krb-x.xx-sol10-sparc',
      })
    }
    it {
      should contain_package('SUNWkrbu').with({
        'adminfile' => '/sw/Solaris/Sparc/noask',
        'provider'  => 'sun',
        'source'    => '/sw/Solaris/Sparc/krb/krb-x.xx-sol10-sparc',
      })
    }
    it { should contain_file('krb5conf').with({
      'path'   => '/etc/krb5.conf',
      'ensure' => 'present',
      'owner'  => 'root',
      'group'  => 'root',
      'mode'   => '0644',
    }) }
    it { should contain_file('krb5directory').with({
      'path'   => '/etc/krb5',
      'ensure' => 'directory',
      'owner'  => 'root',
      'group'  => 'root',
    }) }
    it { should contain_file('krb5link').with({
      'path'   => '/etc/krb5/krb5.conf',
      'ensure' => 'link',
      'target' => '/etc/krb5.conf',
    }) }
    krb5conf_fixture = File.read(fixtures("krb5.conf.defaults"))
    it { should contain_file('krb5conf').with_content(krb5conf_fixture) }
  end

  context 'on unsupported osfamily' do
    let(:facts) do { :osfamily => 'unsupported', } end
    it 'should fail' do
      expect {
        should contain_class('krb5')
      }.to raise_error(Puppet::Error,/krb5 only supports default package names for/)
    end
  end

  context 'on unsupported osfamily with package set' do
    let(:facts) do { :osfamily => 'unsupported', } end
    let(:params) do { :package => 'krb5-package', } end
    it { should contain_class('krb5') }
    it { should contain_package('krb5-package') }
    it { should contain_file('krb5conf').with({
      'path'   => '/etc/krb5.conf',
      'ensure' => 'present',
      'owner'  => 'root',
      'group'  => 'root',
      'mode'   => '0644',
    }) }

    krb5conf_fixture = File.read(fixtures("krb5.conf.defaults"))
    it { should contain_file('krb5conf').with_content(krb5conf_fixture) }
  end

  context 'with all parameters set' do
    let(:facts) { { :osfamily => 'RedHat' } }
    let(:params) do
      { :logging_default        => 'FILE:/tmp/log1',
        :logging_kdc            => 'FILE:/tmp/log2',
        :logging_admin_server   => 'FILE:/tmp/log3',
        :logging_krb524d        => 'FILE:/tmp/log4',
        :default_realm          => 'EXAMPLE.COM',
        :dns_lookup_realm       => 'false',
        :dns_lookup_kdc         => 'false',
        :ticket_lifetime        => '24h',
        :default_ccache_name    => 'FILE:/tmp/krb5cc_%{uid}',
        :default_keytab_name    => '/etc/opt/quest/vas/host.keytab',
        :forwardable            => 'true',
        :allow_weak_crypto      => 'false',
        :proxiable              => 'true',
        :rdns                   => 'false',
        :default_tkt_enctypes   => 'aes256-cts',
        :default_tgs_enctypes   => 'aes128-cts',
        :realms                 => {
          'EXAMPLE.COM'         => {
            'default_domain'    => 'example.com',
            'kdc'               => [ 'kdc1.example.com:88', 'kdc2.example.com:88', ],
            'admin_server'      => [ 'kdc1.example.com:749', 'kdc2.example.com:749', ],
          },
          'ANOTHER.EXAMPLE.COM' => {
            'default_domain'    => 'another.example.com',
            'kdc'               => 'kdc1.another.example.com:88',
            'admin_server'      => 'kdc1.another.example.com:749',
          },
        },
        :appdefaults            => {
          'pam'                 => {
            'debug'             => 'false',
            'ticket_lifetime'   => '36000',
            'renew_lifetime'    => '36000',
            'forwardable'       => 'true',
            'krb4_convert'      => 'false',
          },
        },
        :domain_realm           => {
          'example.com'         => 'EXAMPLE.COM',
        },
        :package                => 'krb5-package',
        :krb5conf_file          => '/etc/kerberos/krb5.conf',
        :krb5conf_ensure        => 'file',
        :krb5conf_owner         => 'kerberos',
        :krb5conf_group         => 'kerberos',
        :krb5conf_mode          => '0600',
      }
    end

    it { should contain_class('krb5') }
    it { should contain_package('krb5-package') }
    it { should contain_file('krb5conf').with({
      'path'   => '/etc/kerberos/krb5.conf',
      'ensure' => 'file',
      'owner'  => 'kerberos',
      'group'  => 'kerberos',
      'mode'   => '0600',
    }) }

    krb5conf_fixture = File.read(fixtures("krb5.conf.allset"))
    it { should contain_file('krb5conf').with_content(krb5conf_fixture) }
  end

  context 'with logging parameters that have default values set to <> (overriding default values)' do
    let(:facts) do
      {
        :osfamily => 'RedHat',
      }
    end
    let(:params) do
      {
        :logging_default      => '',
        :logging_kdc          => '',
        :logging_admin_server => '',
      }
    end
    it { should contain_class('krb5') }
    it { should contain_package('krb5-libs') }
    it { should contain_file('krb5conf').with({
      'path'   => '/etc/krb5.conf',
      'ensure' => 'present',
      'owner'  => 'root',
      'group'  => 'root',
      'mode'   => '0644',
    }) }

    it { should contain_file('krb5conf').with_content("#Managed by puppet, any changes will be overwritten\n") }
  end

end
