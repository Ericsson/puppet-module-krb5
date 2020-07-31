# puppet-module-krb5

[![Build Status](https://travis-ci.org/kodguru/puppet-module-krb5.png?branch=master)](https://travis-ci.org/kodguru/puppet-module-krb5)

Module to manage the kerberos config file and client packages.


# Compatibility
This module has been tested to work on the following systems with the latest
Puppet v3, v3 with future parser, v4, v5 and v6. See `.travis.yml` for the
exact matrix of supported Puppet and ruby versions.

* Debian
* EL 6
* EL 7
* EL 8
* Suse
* Solaris 10
* Solaris 11


### Parameters
---
#### logging_default (type: String)
Value for `default` in `[logging]` section of `krb5.conf`.

- Default: **'FILE:/var/log/krb5libs.log'**

---
#### logging_kdc (type: String)
Value for `kdc` in `[logging]` section of `krb5.conf`.

- Default: **'FILE:/var/log/krb5kdc.log'**

---
#### logging_admin_server (type: String)
Value for `admin_server` in `[logging]` section of `krb5.conf`.

- Default: **'FILE:/var/log/kadmind.log'**

---

#### logging_krb524d (type: String)
Value for `krb524d` in `[logging]` section of `krb5.conf`.

- Default: **undef**

---
#### default_realm (type: String)
Value for `default_realm` in `[libdefaults]` section of `krb5.conf`. Default realm.

- Default: **undef**

---
#### dns_lookup_realm (type: Boolean)
Value for `dns_lookup_realm` in `[libdefaults]` section of `krb5.conf`. To use dns to lookup realm.

- Default: **undef**

---
#### dns_lookup_kdc (type: Boolean)
Value for `dns_lookup_kdc` in `[libdefaults]` section of `krb5.conf`. To use dns to lookup kdc.

- Default: **undef**

---
#### ticket_lifetime (type: String)
Value for `ticket_lifetime` in `[libdefaults]` section of `krb5.conf`.

- Default: **undef**

---
#### default_ccache_name (type: String)
Value for `default_ccache_name` in `[libdefaults]` section of `krb5.conf`. This setting is supported by Kerberos version >= v1.11.

- Default: **undef**

---
#### default_keytab_name (type: Absolute Path as String)
Value for `default_keytab_name` in `[libdefaults]` section of `krb5.conf`. Name of keytab file.

- Default: **undef**
---
#### forwardable (type: Boolean)
Value for `forwardable` in `[libdefaults]` section of `krb5.conf`. If ticket is forwardable.

- Default: **undef**

----
#### allow_weak_crypto (type: Boolean)
Value for `allow_weak_crypto` in `[libdefaults]` section of `krb5.conf`. If weak encryption types are allowed.

- Default: **undef**

---
#### proxiable (type: Boolean)
Value for `proxiable` in `[libdefaults]` section of `krb5.conf`. If ticket is proxiable.

- Default: **undef**

---
#### rdns (type: Boolean)
Value for `rdns` in `[libdefaults]` section of `krb5.conf`. If reverse DNS resolution should be used.

- Default: **undef**

---
#### default_tkt_enctypes (type: String)
Value for `default_tkt_enctypes` in `[libdefaults]` section of `krb5.conf`.

- Default: **undef**

---
#### default_tgs_enctypes (type: String)
Value for `default_tgs_enctypes` in `[libdefaults]` section of `krb5.conf`.

- Default: **undef**

---
#### realms (type: Hash)
Content for `[realms]` section of `krb5.conf`. List of kerberos domains (hash with nested arrays).

- Default: **{}**

##### Example using Hiera
```yaml
krb5::realms:
  'EXAMPLE.COM':
    default_domain:
      - 'example.com'
    kdc:
      - 'kdc1.example.com:88'
      - 'kdc2.example.com:88'
    admin_server:
      - 'kdc1.example.com:749'
      - 'kdc2.example.com:749'
```

Create this `[realms]` section in `krb5.conf`.
```
[realms]
EXAMPLE.COM = {
  admin_server = kdc1.example.com:749
  admin_server = kdc2.example.com:749
  default_domain = example.com
  kdc = kdc1.example.com:88
  kdc = kdc2.example.com:88
}
```

---
#### appdefaults (type: Hash)
Content for `[appdefaults]` section of `krb5.conf`. List of defaults for apps (hash with nested arrays).

- Default: **{}**

##### Example using Hiera
```yaml
krb5::appdefaults:
  pam:
    'debug': 'false'
    'ticket_lifetime': '36000'
    'renew_lifetime': '36000'
    'forwardable': 'true'
    'krb4_convert': 'false'
```
Create this `[appdefaults]` section in `krb5.conf`.
```
[appdefaults]
pam = {
         debug = false
         forwardable = true
         krb4_convert = false
         renew_lifetime = 36000
         ticket_lifetime = 36000
}
```

---
#### domain_realm
Content for `[domain_realm]` section of `krb5.conf`. List of domain realms (hash with nested arrays).

- Default: **{}**

##### Example using Hiera
```yaml

krb5::domain_realm:
  'example.com': 'EXAMPLE.COM'
```
Create this `[domain_realm]` section in `krb5.conf`.
```
[domain_realm]
.example.com = EXAMPLE.COM
example.com = EXAMPLE.COM
```

---
#### package (type: Array)
Array of the related kerberos packages. [] will choose the appropriate default for the system. Support for type string is deprecated.

- Default: **[]**

---
#### package_adminfile (type: String)
Solaris specific: path to package adminfile.

- Default: **undef**

---
#### package_provider (type: String)
Solaris specific (mostly), package provider for `$package`, valid values are '`sun`' and '`pkg`'.

- Default: **undef**

---
#### package_source (type: String)
Solaris specific (mostly): path to package source.

- Default: **undef**

---
#### krb5conf_file (type: String)
Path to config file.

- Default: **'/etc/krb5.conf'**
---
#### krb5conf_ensure (type: String)
Ensure attribute to be used for `$krb5conf_file`, valid values are '`present`', '`absent`', '`file`', '`directory`', and '`link`'.

- Default: **'present'**

---
#### krb5conf_owner (type: String)
File system owner of the config file.

- Default: **'root'**

---
#### krb5conf_group (type: String)
File system group of the config file.

- Default: **'root'**

---
#### krb5conf_mode (type: String)
File mode in four digit octal notation to be used for `$krb5conf_file`.

- Default: **'0644'**

---
#### krb5key_link_target (type: String)
Create symlink /etc/krb5.keytab with target specified.

- Default: **undef**
---
