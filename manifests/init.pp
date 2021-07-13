# Manage the kerberos config file and client packages
class krb5 (
    $logging_default      = 'FILE:/var/log/krb5libs.log',
    $logging_kdc          = 'FILE:/var/log/krb5kdc.log',
    $logging_admin_server = 'FILE:/var/log/kadmind.log',
    $logging_krb524d      = undef,
    $default_realm        = undef,
    $dns_lookup_realm     = undef,
    $dns_lookup_kdc       = undef,
    $ticket_lifetime      = undef,
    $default_ccache_name  = undef,
    $default_keytab_name  = undef,
    $forwardable          = undef,
    $allow_weak_crypto    = undef,
    $proxiable            = undef,
    $realms               = {},
    $appdefaults          = {},
    $domain_realm         = {},
    $rdns                 = undef,
    $default_tkt_enctypes = undef,
    $default_tgs_enctypes = undef,
    $package              = [],
    $package_adminfile    = undef,
    $package_provider     = undef,
    $package_source       = undef,
    $krb5conf_file        = '/etc/krb5.conf',
    $krb5conf_ensure      = 'present',
    $krb5conf_owner       = 'root',
    $krb5conf_group       = 'root',
    $krb5conf_mode        = '0644',
    $krb5key_link_target  = undef,
) {

  if is_string($logging_default)      == false { fail('krb5::logging_default is not a string.') }
  if is_string($logging_kdc)          == false { fail('krb5::logging_kdc is not a string.') }
  if is_string($logging_admin_server) == false { fail('krb5::logging_admin_server is not a string.') }
  if is_string($logging_krb524d)      == false { fail('krb5::logging_krb524d is not a string.') }
  if is_string($default_ccache_name)  == false { fail('krb5::default_ccache_name is not a string.') }
  if is_string($default_tkt_enctypes) == false { fail('krb5::default_tkt_enctypes is not a string.') }
  if is_string($default_tgs_enctypes) == false { fail('krb5::default_tgs_enctypes is not a string.') }
  if is_string($krb5conf_owner)       == false { fail('krb5::krb5conf_owner is not a string.') }
  if is_string($krb5conf_group)       == false { fail('krb5::krb5conf_group is not a string.') }

  if is_hash($realms)                 == false { fail('krb5::realms is not a hash.') }
  if is_hash($appdefaults)            == false { fail('krb5::appdefaults is not a hash.') }
  if is_hash($domain_realm)           == false { fail('krb5::domain_realm is not a hash.') }

  if $default_keytab_name             != undef { validate_absolute_path($default_keytab_name) }
  if $krb5conf_file                   != undef { validate_absolute_path($krb5conf_file) }
  if $krb5key_link_target             != undef { validate_absolute_path($krb5key_link_target) }
  if $package_adminfile               != undef { validate_absolute_path($package_adminfile) }
  if $package_source                  != undef { validate_absolute_path($package_source) }

  # Workaround is_string() converts strings that contain an integer to the data type integer and
  # then fails because it is no longer a string. WTF!
  if is_string($ticket_lifetime) == false and is_integer($ticket_lifetime) == false { fail('krb5::ticket_lifetime is not a string.') }

  if $default_realm != undef and is_domain_name($default_realm) == false { fail('krb5::default_realm is not a domain name.') }

  validate_re($krb5conf_mode, '^[0-7]{4}$', "krb5::krb5conf_mode is not in four digit octal notation. It is <${krb5conf_mode}>.")

  $file_ensure_valid = ['present', 'absent', 'file', 'directory','link']
  validate_re($krb5conf_ensure, $file_ensure_valid, "krb5::krb5conf_ensure is not a valid value for file type ensure attribute. Check README for valid values, it is <${krb5conf_ensure}>."  ) #lint:ignore:140chars

  if $package_provider != undef {
    $package_provider_valid = ['sun', 'pkg']
    validate_re($package_provider, $package_provider_valid, "krb5::package_provider is not a valid value for package type provider attribute. Check README for valid values, it is <${package_provider}>."  ) #lint:ignore:140chars
  }

  case $dns_lookup_realm {
    true, 'true':   { $dns_lookup_realm_string = 'true' }
    false, 'false': { $dns_lookup_realm_string = 'false' }
    undef:          { $dns_lookup_realm_string = undef }
    default:        { fail('krb5::dns_lookup_realm is not a boolean.') }
  }

  case $dns_lookup_kdc {
    true, 'true':   { $dns_lookup_kdc_string = 'true' }
    false, 'false': { $dns_lookup_kdc_string = 'false' }
    undef:          { $dns_lookup_kdc_string = undef }
    default:        { fail('krb5::dns_lookup_kdc is not a boolean.') }
  }

  case $forwardable {
    true, 'true':   { $forwardable_string = 'true' }
    false, 'false': { $forwardable_string = 'false' }
    undef:          { $forwardable_string = undef }
    default:        { fail('krb5::forwardable is not a boolean.') }
  }

  case $allow_weak_crypto {
    true, 'true':   { $allow_weak_crypto_string = 'true' }
    false, 'false': { $allow_weak_crypto_string = 'false' }
    undef:          { $allow_weak_crypto_string = undef }
    default:        { fail('krb5::allow_weak_crypto is not a boolean.') }
  }

  case $proxiable {
    true, 'true':   { $proxiable_string = 'true' }
    false, 'false': { $proxiable_string = 'false' }
    undef:          { $proxiable_string = undef }
    default:        { fail('krb5::proxiable is not a boolean.') }
  }

  case $rdns {
    true, 'true':   { $rdns_string = 'true' }
    false, 'false': { $rdns_string = 'false' }
    undef:          { $rdns_string = undef }
    default:        { fail('krb5::rdns is not a boolean.') }
  }

  if $package == [] {
    case $::osfamily {
      'RedHat': {
        $package_array = [ 'krb5-libs', 'krb5-workstation' ]
      }
      'Suse': {
        $package_array = [ 'krb5', 'krb5-client' ]
      }
      'Solaris': {
        case $::kernelrelease {
          '5.10': {
            $package_array = [ 'SUNWkrbr', 'SUNWkrbu' ]
          }
          '5.11': {
            $package_array = [ 'pkg:/service/security/kerberos-5' ]
          }
          default: {
            fail("krb5 only supports default package names for Solaris 5.10 and 5.11. Detected kernelrelease is <${::kernelrelease}>. Please specify package name with the \$package variable.") #lint:ignore:140chars
          }
        }
      }
      'Debian': {
        $package_array = [ 'krb5-user' ]
      }
      default: {
        fail("krb5 only supports default package names for Debian, RedHat, Suse and Solaris. Detected osfamily is <${::osfamily}>. Please specify package name with the \$package variable.") #lint:ignore:140chars
      }
    }
  }
  else {
    case type3x($package) {
      'array':  { $package_array = $package }
      'string': { $package_array = [ $package ] }
      default:  { fail('krb5::package is not an array nor a string.') }
    }
  }

  if $package_adminfile != undef {
    Package {
      adminfile => $package_adminfile,
    }
  }

  if $package_provider != undef {
    Package {
      provider => $package_provider,
    }
  }

  if $package_source != undef {
    Package {
      source => $package_source,
    }
  }

  package{ $package_array:
    ensure  => present,
  }

  file{ 'krb5conf':
    ensure  => $krb5conf_ensure,
    path    => $krb5conf_file,
    owner   => $krb5conf_owner,
    group   => $krb5conf_group,
    mode    => $krb5conf_mode,
    content => template('krb5/krb5.conf.erb'),
  }

  if $::osfamily == 'Solaris' {
    file { 'krb5directory' :
      ensure => directory,
      path   => '/etc/krb5',
      owner  => $krb5conf_owner,
      group  => $krb5conf_group,
    }

    file { 'krb5link' :
      ensure  => link,
      path    => '/etc/krb5/krb5.conf',
      target  => $krb5conf_file,
      require => File['krb5directory'],
    }
  }

  if $krb5key_link_target != undef {
    validate_absolute_path($krb5key_link_target)

    file { 'krb5keytab_file':
      ensure => link,
      path   => '/etc/krb5.keytab',
      target => $krb5key_link_target,
    }
  }
}
