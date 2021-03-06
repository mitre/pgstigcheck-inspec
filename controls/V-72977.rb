pg_log_dir = input('pg_log_dir')

pg_dba = input('pg_dba')

pg_dba_password = input('pg_dba_password')

pg_db = input('pg_db')

pg_host = input('pg_host')

pg_audit_log_dir = input('pg_audit_log_dir')

control "V-72977" do
  title "PostgreSQL must generate audit records when unsuccessful attempts to
  add privileges/permissions occur."
  desc  "Failed attempts to change the permissions, privileges, and roles
  granted to users and roles must be tracked. Without an audit trail,
  unauthorized attempts to elevate or restrict privileges could go undetected.

  In an SQL environment, adding permissions is typically done via the GRANT
  command, or, in the negative, the REVOKE command.

  To aid in diagnosis, it is necessary to keep track of failed attempts in
  addition to the successful ones."

  impact 0.5
  tag "severity": "medium"
  tag "gtitle": "SRG-APP-000495-DB-000327"
  tag "gid": "V-72977"
  tag "rid": "SV-87629r2_rule"
  tag "stig_id": "PGS9-00-006900"
  tag "fix_id": "F-79423r1_fix"
  tag "cci": ["CCI-000172"]
  tag "nist": ["AU-12 c", "Rev_4"]
  tag "false_negatives": nil
  tag "false_positives": nil
  tag "documentable": false
  tag "mitigations": nil
  tag "severity_override_guidance": false
  tag "potential_impacts": nil
  tag "third_party_tools": nil
  tag "mitigation_controls": nil
  tag "responsibility": nil
  tag "ia_controls": nil
  desc "check", "First, as the database administrator (shown here as
  \"postgres\"), create a role 'bob' and a test table by running the following
  SQL: 

  $ sudo su - postgres 
  $ psql -c \"CREATE ROLE bob; CREATE TABLE test(id INT);\" 

  Next, set current role to bob and attempt to modify privileges: 

  $ psql -c \"SET ROLE bob; GRANT ALL PRIVILEGES ON test TO bob;\" 

  Now, as the database administrator (shown here as \"postgres\"), verify the
  unsuccessful attempt was logged: 

  $ sudo su - postgres 
  $ cat ${PGDATA?}/pg_log/<latest_log> 
  2016-07-14 18:12:23.208 EDT postgres postgres ERROR: permission denied for
  relation test 
  2016-07-14 18:12:23.208 EDT postgres postgres STATEMENT: GRANT ALL PRIVILEGES
  ON test TO bob; 

  If audit logs are not generated when unsuccessful attempts to add
  privileges/permissions occur, this is a finding."
  
  desc "fix", "Configure PostgreSQL to produce audit records when unsuccessful
  attempts to add privileges occur.

  All denials are logged by default if logging is enabled. To ensure that logging
  is enabled, review supplementary content APPENDIX-C for instructions on
  enabling logging."

  sql = postgres_session(pg_dba, pg_dba_password, pg_host, input('pg_port'))
if file(pg_audit_log_dir).exist?  
  describe sql.query('DROP ROLE IF EXISTS bob; CREATE ROLE bob; CREATE TABLE test(id INT);', [pg_db]) do
    its('output') { should match /CREATE TABLE/ }
  end

  describe sql.query('SET ROLE bob; GRANT ALL PRIVILEGES ON test TO bob;', [pg_db]) do
    its('output') { should match /\nERROR:  permission denied for relation test\ncommand terminated with exit code 1\n/ }
  end

  describe command("cat `find #{pg_audit_log_dir} -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d\" \"` | grep \"permission denied for relation test\"") do
    its('stdout') { should match /^.*permission denied for relation test.*$/ }
  end 
  
  describe sql.query('DROP ROLE bob; DROP TABLE "test" CASCADE', [pg_db]) do
  end
else
  describe "The #{pg_audit_log_dir} directory was not found. Check path for this postgres version/install to define the value for the 'pg_audit_log_dir' inspec input parameter." do
    skip "The #{pg_audit_log_dir} directory was not found. Check path for this postgres version/install to define the value for the 'pg_audit_log_dir' inspec input parameter."
  end
end

end
