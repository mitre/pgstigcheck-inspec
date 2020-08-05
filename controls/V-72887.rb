pg_ver = input('pg_version')

pg_dba = input('pg_dba')

pg_dba_password = input('pg_dba_password')

pg_db = input('pg_db')

pg_host = input('pg_host')

pg_timezone = input('pg_timezone')

control "V-72887" do
  title "PostgreSQL must record time stamps, in audit records and application
  data, that can be mapped to Coordinated Universal Time (UTC, formerly GMT)."
  desc  "If time stamps are not consistently applied and there is no common
  time reference, it is difficult to perform forensic analysis.

  Time stamps generated by PostgreSQL must include date and time. Time is
  commonly expressed in Coordinated Universal Time (UTC), a modern continuation
  of Greenwich Mean Time (GMT), or local time with an offset from UTC."

  impact 0.5
  tag "severity": "medium"
  tag "gtitle": "SRG-APP-000374-DB-000322"
  tag "gid": "V-72887"
  tag "rid": "SV-87539r2_rule"
  tag "stig_id": "PGS9-00-002400"
  tag "fix_id": "F-79329r4_fix"
  tag "cci": ["CCI-001890"]
  tag "nist": ["AU-8 b", "Rev_4"]
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
  desc "check", "Note: The following instructions use the PGDATA environment
  variable. See supplementary content APPENDIX-F for instructions on configuring
  PGDATA.

  When a PostgreSQL cluster is initialized using initdb, the PostgreSQL cluster
  will be configured to use the same time zone as the target server.

  As the database administrator (shown here as \"postgres\"), check the current
  log_timezone setting by running the following SQL:

  $ sudo su - postgres
  $ psql -c \"SHOW log_timezone\"

  log_timezone
  --------------
  UTC
  (1 row)

  If log_timezone is not set to the desired time zone, this is a finding."
  
  desc "fix", "Note: The following instructions use the PGDATA and PGVER
  environment variables. See supplementary content APPENDIX-F for instructions on
  configuring PGDATA and APPENDIX-H for PGVER.

  To change log_timezone in postgresql.conf to use a different time zone for
  logs, as the database administrator (shown here as \"postgres\"), run the
  following: 

  $ sudo su - postgres 
  $ vi ${PGDATA?}/postgresql.conf 
  log_timezone='UTC' 

  Next, restart the database: 

  # SYSTEMD SERVER ONLY 
  $ sudo systemctl reload postgresql-${PGVER?}

  # INITD SERVER ONLY 
  $ sudo service postgresql-${PGVER?} reload"

  sql = postgres_session(pg_dba, pg_dba_password, pg_host, pg_port)

  describe sql.query('SHOW log_timezone;', [pg_db]) do
    its('output') { should eq pg_timezone }
  end
end
