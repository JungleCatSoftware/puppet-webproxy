# == Class: webproxy
#
# Full description of class webproxy here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'webproxy':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2016 Your name here, unless otherwise noted.
#
class webproxy (
  $basehostname      = 'example.net',
  $accounts_pool     = undef,
  $accounts_api_pool = undef,
){

  validate_string($basehostname)
  validate_array($accounts_pool)
  validate_array($accounts_api_pool)

  include nginx

  # Upstream server pools
  nginx::resource::upstream { 'accounts':
    members => $accounts_pool,
  }
  nginx::resource::upstream { 'accounts-api':
    members => $accounts_api_pool,
  }

  # VHosts
  nginx::resource::vhost { "accounts.${basehostname}":
    proxy => 'http://accounts',
  }
  nginx::resource::location { '~ /api/(.*)':
    vhost => "accounts.${basehostname}",
    proxy => 'http://accounts-api/$1',
  }
  nginx::resource::vhost { "api.accounts.${basehostname}":
    proxy => 'http://accounts-api',
  }

}
