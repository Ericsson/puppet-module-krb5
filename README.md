# puppet-module-krb5
===

[![Build Status](https://travis-ci.org/kodguru/puppet-module-krb5.png?branch=master)](https://travis-ci.org/kodguru/puppet-module-krb5)

Module to manage the kerberos config file and client packages

===

# Compatibility
---------------
This module has been tested to work on the following systems with the latest
Puppet v3, v3 with future parser, v4, v5 and v6. See `.travis.yml` for the
exact matrix of supported Puppet and ruby versions.

* Debian
* RHEL 6
* RHEL 7
* Suse
* Solaris 10
* Solaris 11

===

# Parameters
------------

---
#### logging_default (type: String)
Value for `default` in `logging` section of krb5.conf.

- *Default*: 'FILE:/var/log/krb5libs.log'

---
#### logging_kdc (type: String)
Value for `kdc` in `logging` section of krb5.conf.

- *Default*: 'FILE:/var/log/krb5kdc.log'

---
#### logging_admin_server (type: String)
Value for `admin_server` in `logging` section of krb5.conf.

- *Default*: 'FILE:/var/log/kadmind.log'

---

#### logging_krb524d (type: String)
Value for `krb524d` in `logging` section of krb5.conf.

- *Default*: undef

---

default_realm
-------------
Default realm

- *Default*: undef

dns_lookup_realm
----------------
Boolean to use dns to lookup realm

- *Default*: undef

dns_lookup_kdc
--------------
Boolean to use dns to lookup kdc

- *Default*: undef

---
#### ticket_lifetime (type: String)
Value for `ticket_lifetime` in `libdefaults` section of krb5.conf.

- *Default*: undef

---
#### default_ccache_name (type: String)
Value for `default_ccache_name` in `libdefaults` section of krb5.conf. This setting is supported by Kerberos version >= v1.11.

- *Default*: undef

---
#### default_keytab_name (type: Absolute Path as String)
Value for `default_keytab_name` in `libdefaults` section of krb5.conf. Name of keytab file.

- *Default*: undef
---

forwardable
-----------
Boolean if ticket is forwardable

- *Default*: undef

allow_weak_crypto
-----------------
Boolean if weak encryption types are allowed

- *Default*: undef

proxiable
---------
Boolean if ticket is proxiable

- *Default*: undef

rdns
----
Boolean if reverse DNS resolution should be used

- *Default*: undef

---
#### default_tkt_enctypes (type: String)
Value for `default_tkt_enctypes` in `libdefaults` section of krb5.conf.

- *Default*: undef

---
#### default_tgs_enctypes (type: String)
Value for `default_tgs_enctypes` in `libdefaults` section of krb5.conf.

- *Default*: undef

---
realms
------
List of kerberos domains (hash with nested arrays)

- *Default*: undef

- *Hiera example*:
<pre>
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
</pre>

appdefaults
-----------
List of defaults for apps

- *Default*: undef

- *Hiera example*:
<pre>
krb5::appdefaults:
  pam:
    'debug': 'false'
    'ticket_lifetime': '36000'
    'renew_lifetime': '36000'
    'forwardable': 'true'
    'krb4_convert': 'false'
</pre>

domain_realm
------------
List of domain realms

- *Default*: undef

- *Hiera example*:
<pre>
krb5::domain_realm:
  'example.com': 'EXAMPLE.COM'
</pre>

---
#### package (type: Array)
Array of the related kerberos packages. [] will choose the appropriate default for the system. Support for type string is deprecated.

- *Default*: []

---
#### package_adminfile (type: Absolute Path as String)
Solaris specific: path to package adminfile.

- *Default*: undef

---
package_provider
----------------
Solaris specific (mostly): string for package provider.

- *Default*: undef

---
#### package_source (type: Absolute Path as String)
Solaris specific (mostly): path to package source.

- *Default*: undef

---
#### krb5conf_file (type: Absolute Path as String)
Path to config file.

- *Default*: /etc/krb5.conf
---

krb5conf_ensure
---------------
Ensure of the config file

- *Default*: present

---
#### krb5conf_owner (type: String)
Owner of the config file.

- *Default*: root

---
#### krb5conf_group (type: String)
Group of the config file.

- *Default*: root

---
krb5conf_mode
-------------
Mode of the config file

- *Default*: 0644

---
#### krb5key_link_target (type: Absolute Path as String)
Create symlink /etc/krb5.keytab with target specified.

- *Default*: undef
---
