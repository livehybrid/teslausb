#!/bin/bash -eu
ENABLE_SPLUNK="$1"
SPLUNK_DEPLOYMENTSERVER="$2"
ENABLE_SPLUNK=${ENABLE_SPLUNK:-false}
SPLUNK_DEPLOYMENTSERVER=${SPLUNK_DEPLOYMENTSERVER:-false}

if [ "$ENABLE_SPLUNK" = "true" ]
then

/opt/splunkforwarder/bin/splunk stop || echo "Splunk is not already running"
cd /backingfiles
wget -O splunkforwarder-8.1.3-63079c59e632-Linux-arm.tgz 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=ARMv6&platform=linux&version=8.1.3&product=universalforwarder&filename=splunkforwarder-8.1.3-63079c59e632-Linux-arm.tgz&wget=true'
tar -xf splunkforwarder-8.1.3-63079c59e632-Linux-arm.tgz
rm -f splunkforwarder-8.1.3-63079c59e632-Linux-arm.tgz
id -u splunk &>/dev/null || adduser --gecos "" --disabled-password splunk

ln -s /backingfiles/splunkforwarder /opt/splunkforwarder || true
chown -R splunk: /opt/splunkforwarder
chown -R splunk: /backingfiles/splunkforwarder

cat <<EOF | sudo -u splunk tee /opt/splunkforwarder/etc/system/local/user-seed.conf
[user_info]
USERNAME=admin
PASSWORD=Password1
EOF
chown -hR splunk /backingfiles/splunkforwarder

/opt/splunkforwarder/bin/splunk enable boot-start -systemd-managed 0 -user splunk --accept-license

/opt/splunkforwarder/bin/splunk restart

if [ "$SPLUNK_DEPLOYMENTSERVER" != "false" ]
then
  echo "Setting deployment server to $SPLUNK_DEPLOYMENTSERVER"
  /opt/splunkforwarder/bin/splunk set deploy-poll $SPLUNK_DEPLOYMENTSERVER -auth admin:Password1
else
  echo "Not setting Splunk deployment server"
fi

/opt/splunkforwarder/bin/splunk restart

else
  echo "Not configuring Splunk - ENABLE_SPLUNK is false"
fi
