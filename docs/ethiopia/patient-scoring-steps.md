# Patient Scoring - Quick Steps

## Deploy

```bash
# From local machine
cd /path/to/simple-standalone

# Demo
ansible-playbook patient_scoring.yml -i hosts/ethiopia_demo --ask-vault-pass

# Production
ansible-playbook patient_scoring.yml -i hosts/ethiopia_production --ask-vault-pass
```

## Verify

```bash
# SSH to server
ssh ubuntu@167.71.226.153  # Demo
ssh ubuntu@197.156.66.181  # Production

# Check Docker
docker --version

# Check script
ls -la /home/deploy/patient-scoring/

# Check cron
sudo crontab -u deploy -l | grep patient
```

## Run Manually

```bash
sudo su deploy
/home/deploy/patient-scoring/patient_scoring.sh
```

## Check Results

```bash
exit
sudo su postgres

# Demo
psql -c "SELECT COUNT(*) FROM patient_scores;" demo-simple-server-db

# Production
psql -c "SELECT COUNT(*) FROM patient_scores;" production-simple-server-db
```

## Check Logs

```bash
cat /home/deploy/patient-scoring/patient_scoring.log
```
