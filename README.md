# puppet-module-krb5
===

[![Build Status](https://travis-ci.org/emahags/puppet-module-krb5.png?branch=master)](https://travis-ci.org/emahags/puppet-module-krb5)

Module to manage the kerberos config file

===

# Compatibility
---------------
This module is built for use with Puppet v3 on the following OS families.

* Debian
* RHEL 6
* Suse
* Solaris

===

# Parameters
------------

logging_default
---------------
Default logging

- *Default*: FILE:/var/log/krb5libs.log

logging_kdc
-----------
Default kdc logging

- *Default*: FILE:/var/log/krb5kdc.log

logging_admin_server
--------------------
Default admin server logging

- *Default*: FILE:/var/log/kadmind.log

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

ticket_lifetime
---------------
Lifetime of kerberos ticket

- *Default*: undef

default_keytab_name
-------------------
Name of keytab file

- *Default*: undef

forwardable
-----------
Boolean if ticket is forwardable

- *Default*: undef

proxiable
---------
Boolean if ticket is proxiable

- *Default*: undef

rdns
----
Boolean if reverse DNS resolution should be used

- *Default*: undef

realms
------
List of kerberos domains

- *Default*: undef

- *Hiera example*:
<pre>
krb5::realms:
  'EXAMPLE.COM':
    default_domain: 'example.com'
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

package
-------
String with the related kerberos package to install. 'USE_DEFAULTS' will choose the appropriate default for the system.

- *Default*: 'USE_DEFAULTS'

package_adminfile
-----------------
Solaris specific: string for package adminfile.

- *Default*: undef

package_provider
----------------
Solaris specific (mostly): string for package provider.

- *Default*: undef

package_source
--------------
Solaris specific (mostly): string for package source.

- *Default*: undef

krb5conf_file
-------------
Path to config file

- *Default*: /etc/krb5.conf

krb5conf_ensure
---------------
Ensure of the config file

- *Default*: present

krb5conf_owner
--------------
Owner of the config file

- *Default*: root

krb5conf_group
--------------
Group of the config file

- *Default*: root

krb5conf_mode
-------------
Mode of the config file

- *Default*: 0644
