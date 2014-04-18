include_recipe 'ohai'
include_recipe 'apt'
include_recipe 'hostname'
include_recipe 'git'
include_recipe 'postfix'

node.set['build_essential']['compiletime'] = true

node.packages.each do |package_name|
  package package_name
end

bash "setup self-signed certificate for postfix" do
  user "root"
  cwd "/"
  code <<-EOH
    openssl genrsa -des3 -out staging.rjc2014.ru.key 2048
    chmod 600 staging.rjc2014.ru.key

    openssl req -new -key staging.rjc2014.ru.key -out staging.rjc2014.ru.csr
    openssl x509 -req -days 365 -in staging.rjc2014.ru.csr -signkey staging.rjc2014.ru.key -out staging.rjc2014.ru.crt

    openssl rsa -in staging.rjc2014.ru.key -out staging.rjc2014.ru.key.nopass
    mv staging.rjc2014.ru.key.nopass staging.rjc2014.ru.key

    openssl req -new -x509 -extensions v3_ca -keyout cakey.pem -out cacert.pem -days 3650
    chmod 600 staging.rjc2014.ru.key
    chmod 600 cakey.pem

    mv staging.rjc2014.ru.key /etc/ssl/private/
    mv staging.rjc2014.ru.crt /etc/ssl/certs/
    mv cakey.pem /etc/ssl/private/
    mv cacert.pem /etc/ssl/certs/

    postconf -e 'smtpd_tls_auth_only = no'
    postconf -e 'smtp_use_tls = yes'
    postconf -e 'smtpd_use_tls = yes'
    postconf -e 'smtp_tls_note_starttls_offer = yes'
    postconf -e 'smtpd_tls_key_file = /etc/ssl/private/staging.rjc2014.ru.key'
    postconf -e 'smtpd_tls_cert_file = /etc/ssl/certs/staging.rjc2014.ru.crt'
    postconf -e 'smtpd_tls_CAfile = /etc/ssl/certs/cacert.pem'
    postconf -e 'smtpd_tls_loglevel = 1'
    postconf -e 'smtpd_tls_received_header = yes'
    postconf -e 'smtpd_tls_session_cache_timeout = 3600s'
    postconf -e 'tls_random_source = dev:/dev/urandom'
    postconf -e 'myhostname = staging.rjc2014.ru'
  EOH
end
# TODO: and reload postfix
