#    Copyright 2013 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
#
# these parameters need to be accessed from several locations and
# should be considered to be constant
class percona::params {

  $mysql_user             = 'wsrep_sst'
  $mysql_password         = 'password'
  $service_name           = 'mysql'
  #TODO(bogdando) remove code duplication for galera and mysql manifests to openstack::db in 'I' release
  #limit buffer size to 10G
  $buffer_size             =
    inline_template("<%= [(${::memorysize_mb} * 0.2 + 0).floor, 10000].min %>")
  $mysql_buffer_pool_size  =  "${buffer_size}M"
  $mysql_log_file_size     =
    inline_template("<%= [(${buffer_size} * 0.2 + 0).floor, 2047].min %>M")
  $wait_timeout            = '1800'
  $myisam_sort_buffer_size = '64M'
  $key_buffer_size         = '64M'
  $table_open_cache        = '10000'
  $open_files_limit        = '102400'
  $innodb_flush_method     = 'O_DIRECT'
  $max_connections         = '4096'

  case $::osfamily {
    'RedHat': {
      $mysql_server_name    = 'percona-xtradb-cluster-server-5.6'
      $mysql_client_name    = 'percona-xtradb-cluster-client-5.6'
      $libgalera_package    = 'percona-xtradb-cluster-galera-3.x'
      $libgalera_prefix     = '/usr/lib64'
    }
    'Debian': {
      $mysql_server_name    = 'percona-xtradb-cluster-server-5.6'
      $mysql_client_name    = 'percona-xtradb-cluster-client-5.6'
      $libgalera_package    = 'percona-xtradb-cluster-galera-3.x'
      $libgalera_prefix     = '/usr/lib'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}, module ${module_name} only support osfamily RedHat and Debian")
    }
  }

}
