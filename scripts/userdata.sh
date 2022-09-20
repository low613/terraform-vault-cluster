#! /bin/bash

vault_path="/etc/vault.d/vault.hcl" 
private_ip=$(TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` \
&& curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/local-ipv4)
hostname=$(hostname)
echo ${private_key} | base64 -d > "/opt/vault/tls/vault-key.pem"
echo ${pub_key} | base64 -d > "/opt/vault/tls/vault-cert.pem"
echo ${ca} | base64 -d > "/opt/vault/tls/vault-ca.pem"
chown root:vault /opt/vault/tls/vault-key.pem
chown root:root /opt/vault/tls/vault-cert.pem /opt/vault/tls/vault-ca.pem
chmod 0644 /opt/vault/tls/vault-cert.pem /opt/vault/tls/vault-ca.pem
sudo chmod 0640 /opt/vault/tls/vault-key.pem
sed -i "s/HOSTNAME/$private_ip/g" "$vault_path"
sed -i "s/AWS_REGION/${region}/g" "$vault_path"
sed -i "s/KMS_KEY_ARN/arn:aws:kms:${region}:${account}:key\/${kms_id}/g" "$vault_path"
sed -i "s/UNIQUE_ID/$hostname/g" "$vault_path"
systemctl enable vault.service
systemctl start vault.service
