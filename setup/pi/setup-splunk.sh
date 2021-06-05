#!/bin/bash -eu

cd /opt
wget -O splunkforwarder-8.1.3-63079c59e632-Linux-arm.tgz 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=ARMv6&platform=linux&version=8.1.3&product=universalforwarder&filename=splunkforwarder-8.1.3-63079c59e632-Linux-arm.tgz&wget=true'
tar -xf splunkforwarder-8.1.3-63079c59e632-Linux-arm.tgz
rm -f splunkforwarder-8.1.3-63079c59e632-Linux-arm.tgz
adduser splunk
cat <<EOF | sudo -u splunk tee /opt/splunkforwarder/etc/system/local/user-seed.conf
username=admin
password=Password1
EOF

chown -hR splunk /opt/splunkforwarder
/opt/splunkforwarder/bin/splunk enable boot-start -systemd-managed 0 -user splunk --accept-license
/opt/splunk/bin/splunk start
