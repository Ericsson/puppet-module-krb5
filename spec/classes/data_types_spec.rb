require 'spec_helper'
describe 'krb5', type: :class do
  describe 'variable type and content validations' do
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

      validations = {
        'Array' => {
          name:    ['package'],
          valid:   [['testing']],
          invalid: ['string', { 'ha' => 'sh' }, 3, 2.42, false],
          message: 'expects an Array',
        },
        'Optional[Boolean]' => {
          name:    ['dns_lookup_realm', 'dns_lookup_kdc', 'forwardable', 'allow_weak_crypto', 'proxiable', 'rdns'],
          valid:   [true, false],
          invalid: ['false', 'string', ['array'], { 'ha' => 'sh' }, 3, 2.42],
          message: 'expects a value of type Undef or Boolean,',
        },
        'Hash' => {
          name:    ['realms', 'appdefaults', 'domain_realm'],
          valid:   [], # valid hashes are to complex to block test them here.
          invalid: ['string', 3, 2.42, ['array'], false],
          message: 'expects a Hash',
        },
        'Stdlib::Absolutepath' => {
          name:    ['default_keytab_name', 'package_adminfile', 'package_source ', 'krb5conf_file', 'krb5key_link_target'],
          valid:   ['/absolute/filepath', '/absolute/directory/'],
          invalid: ['../invalid', ['/in/valid'], { 'ha' => 'sh' }, 3, 2.42, false],
          message: 'expects a Stdlib::Absolutepath',
        },
        'String' => {
          name:    ['logging_default', 'logging_kdc', 'logging_admin_server'],
          valid:   ['string', ''],
          invalid: [['array'], { 'ha' => 'sh' }, 3, 2.42, false],
          message: 'expects a String value',
        },
        'String[1]' => {
          name:    ['krb5conf_owner', 'krb5conf_group'],
          valid:   ['string'],
          invalid: ['', ['array'], { 'ha' => 'sh' }, 3, 2.42, false],
          message: '(expects a String value|expects a String\[1\] value)',
        },
        'Optional[String[1]]' => {
          name:    ['logging_krb524d', 'default_ccache_name', 'default_tkt_enctypes', 'default_tgs_enctypes', 'ticket_lifetime'],
          valid:   ['string'],
          invalid: ['', ['array'], { 'ha' => 'sh' }, 3, 2.42, false],
          message: '(expects a String value|value of type Undef or String)',
        },
        'Enum[absent, directory, file, link, present]' => {
          name:    ['krb5conf_ensure'],
          valid:   ['absent', 'directory', 'file', 'link', 'present'],
          invalid: ['string', ['array'], { 'ha' => 'sh' }, 3, 2.42, false],
          message: 'expects a match for Enum',
        },
        'Optional[Enum[pkg, sun]]' => {
          name:    ['package_provider'],
          valid:   ['pkg', 'sun'],
          invalid: ['string', ['array'], { 'ha' => 'sh' }, 3, 2.42, false],
          message: 'match for Enum\[\'pkg\', \'sun\'\]',
        },
        'Stdlib::Host' => {
          name:    ['default_realm'],
          valid:   ['test', 'test.ing', 't.est.ing', '10.2.4.2'],
          invalid: ['spa ce', 'under_score', '-hypheninfront', 'https:/test.ing', ['array'], { 'ha' => 'sh' }, 3, 2.42, false],
          message: 'expect.*Stdlib::Host',
        },
        'Stdlib::Filemode' => {
          name:    ['krb5conf_mode'],
          valid:   ['0644', '0755', '0640', '1740'],
          invalid: [2770, '0844', '00644', 'string', ['array'], { 'ha' => 'sh' }, 3, 2.42, false, nil],
          message: 'expects a match for Stdlib::Filemode|Error while evaluating a Resource Statement',
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
end
