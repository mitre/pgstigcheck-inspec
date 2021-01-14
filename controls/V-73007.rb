pg_conf_file= input('pg_conf_file')

pg_host = input('pg_host')

login_user = input('login_user')

pg_dba = input('pg_dba')

pg_dba_password = input('pg_dba_password')

pg_db = input('pg_db')

approved_ext = input('approved_ext')

control "V-73007" do
  title "Unused database components, PostgreSQL software, and database objects
  must be removed."
  desc  "Information systems are capable of providing a wide variety of
  functions and services. Some of the functions and services, provided by
  default, may not be necessary to support essential organizational operations
  (e.g., key missions, functions). 

  It is detrimental for software products to provide, or install by default,
  functionality exceeding requirements or mission objectives.  

  PostgreSQL must adhere to the principles of least functionality by
  providing only essential capabilities."

  impact 0.5
  tag "severity": "medium"
  tag "gtitle": "SRG-APP-000141-DB-000091"
  tag "gid": "V-73007"
  tag "rid": "SV-87659r2_rule"
  tag "stig_id": "PGS9-00-008900"
  tag "fix_id": "F-79453r2_fix"
  tag "cci": ["CCI-000381"]
  tag "nist": ["CM-7 a", "Rev_4"]
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
  desc "check", "To get a list of all extensions installed, use the following
  commands: 

  $ sudo su - postgres 
  $ psql -c \"select * from pg_extension where extname != 'plpgsql'\" 

  If any extensions exist that are not approved, this is a finding."
  
  desc "fix", "To remove extensions, use the following commands:

  $ sudo su - postgres
  $ psql -c \"DROP EXTENSION <extension_name>\"

  Note: It is recommended that plpgsql not be removed."

sql = postgres_session(input('pg_dba'), input('pg_dba_password'), input('pg_host'), input('pg_port'))

installed_extensions = sql.query('select extname from pg_extension where extname != \'plpgsql\';').lines

  unless installed_extensions.empty?
    installed_extensions.each do |extension|
      describe "The installed extension: #{extension}" do
        subject { extension }
          it { should  be_in input('approved_ext') }
      end
    end
  else
      describe "The list of installed extensions" do
        subject { installed_extensions }
          it { should be_empty }
      end
  end
end
