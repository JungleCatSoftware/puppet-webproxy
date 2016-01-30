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
  $basehostname         = 'example.net',
  $authservicesweb_pool = undef,
  $authservicesapi_pool = undef,
){

  validate_string($basehostname)
  validate_array($authservicesweb_pool)
  validate_array($authservicesapi_pool)

  include nginx

  # Upstream server pools
  nginx::resource::upstream { 'authservicesweb':
    members => $authservicesweb_pool,
  }
  nginx::resource::upstream { 'authservicesapi':
    members => $authservicesapi_pool,
  }

  # VHosts
  nginx::resource::vhost { "authservices.${basehostname}":
    proxy => 'http://authservicesweb',
  }
  nginx::resource::vhost { "api.authservices.${basehostname}":
    proxy => 'http://authservicesapi',
  }

  # Locations
  nginx::resource::location { '~ /api/(.*)':
    vhost       => "authservices.${basehostname}",
    proxy       => 'http://authservicesapi/$1',
    raw_prepend => 'error_page 502 = @apidown;',
  }
  nginx::resource::location { '@apidown':
    vhost         => "authservices.${basehostname}",
    www_root      => '/srv/empty',
    rewrite_rules => ["^/api/(.*)\$ http://api.authservices.${basehostname}/\$1 redirect"],
  }

}
