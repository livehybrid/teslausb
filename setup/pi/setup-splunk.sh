#!/bin/bash -eu
/opt/splunkforwarder/bin/splunk stop || echo "Splunk is not already running"
cd /mutable
wget -O splunkforwarder-8.1.3-63079c59e632-Linux-arm.tgz 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=ARMv6&platform=linux&version=8.1.3&product=universalforwarder&filename=splunkforwarder-8.1.3-63079c59e632-Linux-arm.tgz&wget=true'
tar -xf splunkforwarder-8.1.3-63079c59e632-Linux-arm.tgz
rm -f splunkforwarder-8.1.3-63079c59e632-Linux-arm.tgz
id -u splunk &>/dev/null || adduser --gecos "" --disabled-password splunk

ln -s /mutable/splunkforwarder /opt/splunkforwarder || true

cat <<EOF | sudo -u splunk tee /opt/splunkforwarder/etc/system/local/user-seed.conf
[user_info]
USERNAME=admin
PASSWORD=Password1
EOF

chown -hR splunk /mutable/splunkforwarder

/opt/splunkforwarder/bin/splunk enable boot-start -systemd-managed 0 -user splunk --accept-license
/opt/splunkforwarder/bin/splunk set deploy-poll 192.168.0.14:8089
/opt/splunkforwarder/bin/splunk start
