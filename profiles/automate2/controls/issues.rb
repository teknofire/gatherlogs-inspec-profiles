# level=error msg="Phase failed" error="hab-sup upgrade pending" phase="supervisor upgrade"

upgrade_failed = log_analysis('journalctl_chef-automate.txt', 'level=error msg="Phase failed" error="hab-sup upgrade pending" phase="supervisor upgrade"', a2service: 'service.default')
control 'gatherlogs.automate2.upgrade_failed' do
  impact 1.0
  title 'Check to see if Automate is reporting a failure during the hab sup upgrade process'
  desc "
It appears that there was a failure during the upgrade process for Automate, please
check the logs and contact support to see about getting this fixed."

  tag kb: 'https://automate.chef.io/release-notes/20180706210448/#hanging-stuck-upgrades'
  tag summary: upgrade_failed.summary

  describe upgrade_failed do
    its('last_entry') { should be_empty }
  end
end

ldap_group_too_large = log_analysis('journalctl_chef-automate.txt', 'upstream sent too big header while reading response header from upstream.*dex/auth/ldap', a2service: 'automate-load-balancer.default')
control 'gatherlogs.automate2.auth_upstream_header_too_big' do
  impact 1.0
  title 'Check to see if Automate is reporting a failure getting data from an upstream LDAP source'
  desc "
Automate is reporting errors fetching data from an upstream LDAP source. This commonly
occurs when LDAP returns too many groups or referencing LDAP groups by distinguished names (DN).

See this link to on how to resolve this issue:

https://automate.chef.io/docs/ldap/#other-common-issues
  "

  tag summary: ldap_group_too_large.summary

  describe ldap_group_too_large do
    its('last_entry') { should be_empty }
  end
end

es_gc = log_analysis('journalctl_chef-automate.txt', '\[o.e.m.j.JvmGcMonitorService\] .* \[gc\]', a2service: 'automate-elasticsearch.default')
control 'gatherlogs.automate2.elasticsearch-high-gc-counts' do
  impact 1.0
  title 'Check to see if the ElasticSearch is reporting large number of GC events'
  desc "
The ElasticSearch service is reporting a large number of GC events, this is usually
an indication that the heap size needs to be increased.

Instructions on how to adjust your ElasticSearch heap size: https://automate.chef.io/docs/configuration/#setting-elasticsearch-heap
  "
  tag summary: es_gc.summary

  describe es_gc do
    its('hits') { should cmp <= 10 }
  end
end

es_oom = log_analysis('journalctl_chef-automate.txt', 'java.lang.OutOfMemoryError', a2service: 'automate-elasticsearch.default')
control 'gatherlogs.automate2.elasticsearch_out_of_memory' do
  impact 1.0
  title 'Check to see if Automate is reporting a OutOfMemoryError for ElasticSearch'
  desc "
Automate is reporting OutOfMemoryError for ElasticSearch. Please check to heap size for ElasticSearch
and increase it if necessary or see about increasing the amount of RAM on the system.

https://automate.chef.io/docs/configuration/#setting-elasticsearch-heap
  "

  tag summary: es_oom.summary

  describe es_oom do
    its('last_entry') { should be_empty }
  end
end

# max virtual memory areas vm.max_map_count [256000] is too low, increase to at     least [262144]
es_vmc = log_analysis('journalctl_chef-automate.txt', 'max virtual memory areas vm.max_map_count \[\w+\] is too low, increase to at least \[\w+\]', a2service: 'automate-elasticsearch.default')
control 'gatherlogs.automate2.elasticsearch_max_map_count_error' do
  impact 1.0
  title 'Check to see if Automate ES is reporting a error with vm.max_map_count setting'
  desc "
ElasticSearch is reporting that the vm.max_map_count is not set correctly. This is a sysctl setting
that should be checked by the automate pre-flight tests.  If you recently rebooted make sure
the settings are set in /etc/sysctl.conf

Fix the system tuning failures indicated above by running the following:
sysctl -w vm.max_map_count=262144

To make these changes permanent, add the following to /etc/sysctl.conf:
vm.max_map_count=262144
  "

  tag summary: es_vmc.summary

  describe es_vmc do
    its('last_entry') { should be_empty }
  end
end

lb_workers = log_analysis('journalctl_chef-automate.txt', 'worker_connections are not enough', a2service: 'automate-load-balancer.default')
control 'gatherlogs.automate2.loadbalancer_worker_connections' do
  impact 1.0
  title 'Check to see if Automate is reporting a error with not enough workers for the load balancer'
  desc "
This is an issue with older version of Automate 2 without persistant connections.  Please upgrade to the latest Automate version.
  "

  tag summary: lb_workers.summary

  describe lb_workers do
    its('last_entry') { should be_empty }
  end
end

butterfly_error = log_analysis('journalctl_chef-automate.txt', 'Butterfly error: Error reading or writing to DatFile', a2service: 'hab-sup')
control 'gatherlogs.automate2.butterfly_dat_error' do
  impact 1.0
  title 'Check to see if Automate is reporting an error reading or write to a DatFile'
  desc '
  The Habitat supervisor is having problems reading or writing to an internal DatFile.

  To fix this you will need to remove the failed DatFile and restart the Automate 2 services.
  '

  tag summary: butterfly_error.summary

  describe butterfly_error do
    its('last_entry') { should be_empty }
  end
end

# FATAL:  sorry, too many clients already
pg_client_count = log_analysis('journalctl_chef-automate.txt', 'FATAL:\s+sorry, too many clients already', a2service: 'automate-postgresql.default')
control 'gatherlgos.automate2.postgresql_too_many_clients_error' do
  title 'Check to see if PostgreSQL is complaining about too many client connections'

  desc "
There appears to be too many client connections to PostgreSQL, please contact support
to see how this can be resolved
"

  tag summary: pg_client_count.summary

  describe pg_client_count do
    its('last_entry') { should be_empty }
  end
end
