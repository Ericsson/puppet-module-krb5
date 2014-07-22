require 'spec_helper'
describe 'krb5' do

  context 'with defaults for all parameters' do
    it { should contain_class('krb5') }
    it { should contain_package('krb5-libs') }
    it { should contain_file('krb5conf').with({
      'ensure' => 'present',
      'owner'  => 'root',
      'group'  => 'root',
      'mode'   => '0644',
      'content' => '#Managed by puppet, any changes will be overwritten

[logging]
default = FILE:/var/log/krb5libs.log
kdc = FILE:/var/log/krb5kdc.log
admin_server = FILE:/var/log/kadmind.log
',})}
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
        }
      }
    end
    it { should contain_file('krb5conf').with({
      'content' => '#Managed by puppet, any changes will be overwritten

[logging]
default = FILE:/var/log/krb5libs.log
kdc = FILE:/var/log/krb5kdc.log
admin_server = FILE:/var/log/kadmind.log

[libdefaults]
default_realm = EXAMPLE.COM
dns_lookup_realm = false
dns_lookup_kdc = false
ticket_lifetime = 24h
default_keytab_name = /etc/opt/quest/vas/host.keytab
forwardable = true
proxiable = true

[appdefaults]
pam = {
         debug = false
         forwardable = true
         krb4_convert = false
         renew_lifetime = 36000
         ticket_lifetime = 36000
}

[realms]
EXAMPLE.COM = {
  kdc = kdc1.example.com:88
  kdc = kdc2.example.com:88
  admin_server = kdc1.example.com:749
  admin_server = kdc2.example.com:749
  default_domain = example.com
}

[domain_realm]
.example.com = EXAMPLE.COM
example.com = EXAMPLE.COM
'}) }
  end

  context 'with all logging parameters set to <> (overriding default values)' do
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

end
