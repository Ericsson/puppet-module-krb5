class krb5 (
    $logging_default      = 'FILE:/var/log/krb5libs.log',
    $logging_kdc          = 'FILE:/var/log/krb5kdc.log',
    $logging_admin_server = 'FILE:/var/log/kadmind.log',
    $default_realm        = undef,
    $dns_lookup_realm     = undef,
    $dns_lookup_kdc       = undef,
    $ticket_lifetime      = undef,
    $default_keytab_name  = undef,
    $forwardable          = undef,
    $proxiable            = undef,
    $realms               = undef,
    $appdefaults          = undef,
    $domain_realm         = undef,
    $package              = 'USE_DEFAULTS',
    $krb5conf_file        = '/etc/krb5.conf',
    $krb5conf_ensure      = 'present',
    $krb5conf_owner       = 'root',
    $krb5conf_group       = 'root',
    $krb5conf_mode        = '0644',
) {
  if $package == 'USE_DEFAULTS' {
    case $::osfamily {
      'RedHat': {
        $package_real = 'krb5-libs'
      }
      'Suse': {
        $package_real = 'krb5'
      }
      default: {
        fail("krb5 only supports default package names for RedHat and Suse. Detected osfamily is <${::osfamily}>. Please specify package name with the \$package variable.")
      }
    }
  } else {
    $package_real = $package
  }
  package{ $package_real:
    ensure  => present,
  }

  file{ 'krb5conf':
    path    => $krb5conf_file,
    ensure  => $krb5conf_ensure,
    owner   => $krb5conf_owner,
    group   => $krb5conf_group,
    mode    => $krb5conf_mode,
    content => template('krb5/krb5.conf.erb'),
  }
}
