require 'spec_helper'

describe 'krb5' do

  context 'with defaults for all parameters on RedHat' do
    let(:facts) do { :osfamily => 'RedHat', } end
    it { should contain_class('krb5') }
    it { should contain_package('krb5-libs') }
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

  context 'on unsupported osfamily' do
    let(:facts) do { :osfamily => 'Debian', } end
    it 'should fail' do
      expect {
        should contain_class('krb5')
      }.to raise_error(Puppet::Error,/krb5 only supports default package names for RedHat and Suse./)
    end
  end

  context 'on unsupported osfamily with package set' do
    let(:facts) do { :osfamily => 'Debian', } end
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
    let(:params) do
      { :default_realm        => 'EXAMPLE.COM',
        :dns_lookup_realm     => 'false',
        :dns_lookup_kdc       => 'false',
        :ticket_lifetime      => '24h',
        :default_keytab_name  => '/etc/opt/quest/vas/host.keytab',
        :forwardable          => 'true',
        :proxiable            => 'true',
        :realms               => {
          'EXAMPLE.COM'       => {
            'default_domain'  => 'example.com',
            'kdc'             => [ 'kdc1.example.com:88', 'kdc2.example.com:88', ],
            'admin_server'    => [ 'kdc1.example.com:749', 'kdc2.example.com:749', ],
          },
        },
        :appdefaults          => {
          'pam' => {
            'debug'           => 'false',
            'ticket_lifetime' => '36000',
            'renew_lifetime'  => '36000',
            'forwardable'     => 'true',
            'krb4_convert'    => 'false',
          },
        },
        :domain_realm         => {
          'example.com'       => 'EXAMPLE.COM',
        },
        :package              => 'krb5-package',
      }
    end

    it { should contain_class('krb5') }
    it { should contain_package('krb5-package') }
    it { should contain_file('krb5conf').with({
      'path'   => '/etc/krb5.conf',
      'ensure' => 'present',
      'owner'  => 'root',
      'group'  => 'root',
      'mode'   => '0644',
    }) }

    krb5conf_fixture = File.read(fixtures("krb5.conf.allset"))
    it { should contain_file('krb5conf').with_content(krb5conf_fixture) }
  end

  context 'with all logging parameters set to <> (overriding default values)' do
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

  context 'with logging_default parameter set to <FILE:/var/log/kerberos_default.log>' do
    let(:facts) do
      {
        :osfamily => 'RedHat',
      }
    end
    let(:params) do
      {
        :logging_default      => 'FILE:/var/log/kerberos_default.log',
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

    it { should contain_file('krb5conf').with_content("#Managed by puppet, any changes will be overwritten\n\n\[logging\]\ndefault = FILE:\/var\/log\/kerberos_default.log\n") }
  end

  context 'with logging_kdc parameter set to <FILE:/var/log/kerberos_kdc.log>' do
    let(:facts) do
      {
        :osfamily => 'RedHat',
      }
    end
    let(:params) do
      {
        :logging_default      => '',
        :logging_kdc          => 'FILE:/var/log/kerberos_kdc.log',
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

    it { should contain_file('krb5conf').with_content("#Managed by puppet, any changes will be overwritten\n\n\[logging\]\nkdc = FILE:\/var\/log\/kerberos_kdc.log\n") }
  end

  context 'with logging_admin_server parameter set to <FILE:/var/log/kerberos_admin.log>' do
    let(:facts) do
      {
        :osfamily => 'RedHat',
      }
    end
    let(:params) do
      {
        :logging_default      => '',
        :logging_kdc          => '',
        :logging_admin_server => 'FILE:/var/log/kerberos_admin.log',
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

    it { should contain_file('krb5conf').with_content("#Managed by puppet, any changes will be overwritten\n\n\[logging\]\nadmin_server = FILE:\/var\/log\/kerberos_admin.log\n") }
  end

  context 'with default_realm parameter set to <EXAMPLE.COM> and disabled logging defaults' do
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
        :default_realm        => 'EXAMPLE.COM',
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

    it { should contain_file('krb5conf').with_content("#Managed by puppet, any changes will be overwritten\n\n\[libdefaults\]\ndefault_realm = EXAMPLE.COM\n") }
  end

  context 'with dns_lookup_realm parameter set to <true> and disabled logging defaults' do
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
        :dns_lookup_realm     => 'true',
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

    it { should contain_file('krb5conf').with_content("#Managed by puppet, any changes will be overwritten\n\n\[libdefaults\]\ndns_lookup_realm = true\n") }
  end

  context 'with dns_lookup_kdc parameter set to <true> and disabled logging defaults' do
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
        :dns_lookup_kdc       => 'true',
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

    it { should contain_file('krb5conf').with_content("#Managed by puppet, any changes will be overwritten\n\n\[libdefaults\]\ndns_lookup_kdc = true\n") }
  end

  context 'with ticket_lifetime parameter set to <24200> and disabled logging defaults' do
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
        :ticket_lifetime      => '24200',
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

    it { should contain_file('krb5conf').with_content("#Managed by puppet, any changes will be overwritten\n\n\[libdefaults\]\nticket_lifetime = 24200\n") }
  end

  context 'with default_keytab_name parameter set to </etc/host.keytab> and disabled logging defaults' do
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
        :default_keytab_name  => '/etc/host.keytab',
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

    it { should contain_file('krb5conf').with_content("#Managed by puppet, any changes will be overwritten\n\n\[libdefaults\]\ndefault_keytab_name = /etc/host.keytab\n") }
  end

  context 'with forwardable parameter set to <false> and disabled logging defaults' do
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
        :forwardable          => 'false',
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

    it { should contain_file('krb5conf').with_content("#Managed by puppet, any changes will be overwritten\n\n\[libdefaults\]\nforwardable = false\n") }
  end

  context 'with proxiable parameter set to <false> and disabled logging defaults' do
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
        :proxiable            => 'false',
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

    it { should contain_file('krb5conf').with_content("#Managed by puppet, any changes will be overwritten\n\n\[libdefaults\]\nproxiable = false\n") }
  end

  context 'with realms parameter set to valid hash and disabled logging defaults' do
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
        :realms               => {
          'EXAMPLE.COM'       => {
            'default_domain'  => 'example.com',
            'kdc'             => [ 'kdc1.example.com:88', 'kdc2.example.com:88', ],
            'admin_server'    => [ 'kdc1.example.com:749', 'kdc2.example.com:749', ],
          },
        },
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


    krb5conf_fixture = File.read(fixtures("krb5.conf.realms"))
    it { should contain_file('krb5conf').with_content(krb5conf_fixture) }
  end

  context 'with appdefaults parameter set to valid hash and disabled logging defaults' do
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
        :appdefaults          => {
          'pam' => {
            'debug'           => 'false',
            'ticket_lifetime' => '36000',
            'renew_lifetime'  => '36000',
            'forwardable'     => 'true',
            'krb4_convert'    => 'false',
          },
        },
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


    krb5conf_fixture = File.read(fixtures("krb5.conf.appdefaults"))
    it { should contain_file('krb5conf').with_content(krb5conf_fixture) }
  end

  context 'with domain_realm parameter set to <example.com => EXAMPLE.COM> and disabled logging defaults' do
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
        :domain_realm         => {
          'example.com'       => 'EXAMPLE.COM',
        }
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

    it { should contain_file('krb5conf').with_content("#Managed by puppet, any changes will be overwritten\n\n[domain_realm]\n.example.com = EXAMPLE.COM\nexample.com = EXAMPLE.COM\n") }
  end

  context 'with package parameter set to <krb5-test>' do
    let(:facts) do
      {
        :osfamily => 'RedHat',
      }
    end
    let(:params) do
      {
        :package => 'krb5-test',
      }
    end

    it { should contain_class('krb5') }
    it { should contain_package('krb5-test') }
  end

  context 'with krb5conf_file parameter set to </etc/opt/krb5.conf>' do
    let(:facts) do
      {
        :osfamily => 'RedHat',
      }
    end
    let(:params) do
      {
        :krb5conf_file => '/etc/opt/krb5.conf',
      }
    end

    it { should contain_class('krb5') }
    it { should contain_package('krb5-libs') }

    it { should contain_file('krb5conf').with({
      'path'   => '/etc/opt/krb5.conf',
      'ensure' => 'present',
      'owner'  => 'root',
      'group'  => 'root',
      'mode'   => '0644',
    }) }
  end

end
