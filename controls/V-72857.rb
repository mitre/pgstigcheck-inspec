pg_data_dir = attribute('pg_data_dir')
pg_hba_conf_file = attribute('pg_hba_conf_file')

control 'V-72857' do
  title "If passwords are used for authentication, PostgreSQL must transmit only
         encrypted representations of passwords."
  desc  "The DoD standard for authentication is DoD-approved PKI certificates.
        Authentication based on User ID and Password may be used only when it is
        not possible to employ a PKI certificate, and requires AO approval.

        In such cases, passwords need to be protected at all times, and
        encryption is the standard method for protecting passwords during
        transmission.

        PostgreSQL passwords sent in clear text format across the network are
        vulnerable to discovery by unauthorized users. Disclosure of passwords
        may easily lead to unauthorized access to the database."
  impact 0.5

  tag "gtitle": 'SRG-APP-000172-DB-000075'
  tag "gid": 'V-72857'
  tag "rid": 'SV-87509r1_rule'
  tag "stig_id": 'PGS9-00-000800'
  tag "cci": ['CCI-000197']
  tag "nist": ['IA-5 (1) (c)', 'Rev_4']
  tag "check": "Note: The following instructions use the PGDATA environment
  variable. See supplementary content APPENDIX-F for instructions on configuring
  PGDATA.  As the database administrator (shown here as \"postgres\"), review
  the authentication entries in pg_hba.conf:
  $ sudo su - postgres
  $ cat ${PGDATA?}/pg_hba.conf
  If any entries use the auth_method (last column in records) \"password\", this
  is a finding."
  tag "fix": "Note: The following instructions use the PGDATA environment
  variable. See supplementary content APPENDIX-F for instructions on configuring
  PGDATA.

  As the database administrator (shown here as \"postgres\"), edit
  pg_hba.conf authentication file and change all entries of \"password\" to
  \"md5\":

  $ sudo su - postgres
  $ vi ${PGDATA?}/pg_hba.conf
  host all all .example.com md5"

  describe postgres_hba_conf(pg_hba_conf_file) do
    its('auth_method') { should_not include 'password' }
  end
end
