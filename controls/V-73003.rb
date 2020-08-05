
pg_dba = input('pg_dba')

pg_dba_password = input('pg_dba_password')

pg_db = input('pg_db')

pg_host = input('pg_host')

control "V-73003" do
  title "PostgreSQL must implement cryptographic mechanisms to prevent
  unauthorized modification of organization-defined information at rest (to
  include, at a minimum, PII and classified information) on organization-defined
  information system components."
  desc  "PostgreSQLs handling data requiring \"data at rest\" protections must
  employ cryptographic mechanisms to prevent unauthorized disclosure and
  modification of the information at rest. These cryptographic mechanisms may be
  native to PostgreSQL or implemented via additional software or operating
  system/file system settings, as appropriate to the situation.

  Selection of a cryptographic mechanism is based on the need to protect the
  integrity of organizational information. The strength of the mechanism is
  commensurate with the security category and/or classification of the
  information. Organizations have the flexibility to either encrypt all
  information on storage devices (i.e., full disk encryption) or encrypt specific
  data structures (e.g., files, records, or fields).

  The decision whether and what to encrypt rests with the data owner and is
  also influenced by the physical measures taken to secure the equipment and
  media on which the information resides."

  impact 0.5
  tag "severity": "medium"
  tag "gtitle": "SRG-APP-000428-DB-000386"
  tag "gid": "V-73003"
  tag "rid": "SV-87655r1_rule"
  tag "stig_id": "PGS9-00-008700"
  tag "fix_id": "F-79449r1_fix"
  tag "cci": ["CCI-002475"]
  tag "nist": ["SC-28 (1)", "Rev_4"]
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
  desc "check", "Review the system documentation to determine whether the
  organization has defined the information at rest that is to be protected from
  modification, which must include, at a minimum, PII and classified information.
  If no information is identified as requiring such protection, this is not a
  finding.

  Review the configuration of PostgreSQL, operating system/file system, and
  additional software as relevant.

  If any of the information defined as requiring cryptographic protection from
  modification is not encrypted in a manner that provides the required level of
  protection, this is a finding.

  One possible way to encrypt data within PostgreSQL is to use pgcrypto extension.

  To check if pgcrypto is installed on PostgreSQL, as a database administrator
  (shown here as \"postgres\"), run the following command:

  $ sudo su - postgres
  $ psql -c \"SELECT * FROM pg_available_extensions where name='pgcrypto'\"

  If data in the database requires encryption and pgcrypto is not available, this
  is a finding.

  If disk or filesystem requires encryption, ask the system owner, DBA, and SA to
  demonstrate filesystem or disk level encryption.

  If this is required and is not found, this is a finding."
  
  desc "fix", "Configure PostgreSQL, operating system/file system, and additional
  software as relevant, to provide the required level of cryptographic protection.

  The pgcrypto module provides cryptographic functions for PostgreSQL. See
  supplementary content APPENDIX-E for documentation on installing pgcrypto.

  With pgcrypto installed, it's possible to insert encrypted data into the
  database:

  INSERT INTO accounts(username, password) VALUES ('bob',
crypt('a_secure_password', gen_salt('md5')));"

  sql = postgres_session(pg_dba, pg_dba_password, pg_host, pg_port)

  pgcrypto_sql = "SELECT * FROM pg_available_extensions where name='pgcrypto'"

  describe sql.query(pgcrypto_sql, [pg_db]) do
    its('output') { should_not eq '' }
  end

end
