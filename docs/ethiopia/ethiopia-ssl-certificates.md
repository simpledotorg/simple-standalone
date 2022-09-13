# Installing a new SSL certificate in Simple Server

## Generate the certificate

Install certbot if necessary

```bash
sudo apt-get install certbot
```

Stop haproxy and nginx

```bash
sudo service nginx stop
sudo service haproxy stop
```

Generate a standalone certificate on the server. (for Example, for simple.moh.gov.et domain)

```bash
sudo certbot certonly --standalone -d simple.moh.gov.et
```

Restart haproxy and nginx

```bash
sudo service nginx start
sudo service haproxy start
```

Grab the contents of the generated certificate

```bash
cat /etc/letsencrypt/live/simple.moh.gov.et/privkey.pem
cat /etc/letsencrypt/live/simple.moh.gov.et/fullchain.pem
```

## Check in the new certificate

Fetch the latest updates to the deployment repository.

```bash
cd simple-standalone
git checkout master
git pull --rebase origin master
```
Or if you don't have the clone of the simple-standalone repo on your local machine, 
```bash
git clone https://github.com/simpledotorg/simple-standalone.git
cd simple-standalone
```

Edit the `vault.yml` 

For Example
```bash
make edit-vault hosts=ethiopia_demo
# make sure you are on simple-standalone directory
```

Add(Change) the newly generated fullchain and private key files to the decrypted vault.yml

```yml
ssl_cert_files:
  simple-demo.moh.gov.et:  #'//This is for simple-demo renewal and for the production use the simple.moh.gov.et section:'
    certificate_chain: |
    <Contents of the new fullchain.pem>
  private_key: | 
    <Contents of the new privkey.pem> 
```

alternatively you can decript and encript  the `vault.yml`

```bash
ansible-vault decrypt --vault-id ~/.vault_password_et vault.yml
# Edit what you like and encrypt again
ansible-vault encrypt --vault-id ~/.vault_password_et vault.yml
```
Commit and push your updates. **Caution: Be sure to re-encrypt the `vault.yml` before commiting your changes!**

```bash
cd simple-standalone
git add group_vars/<deployment>/vault.yml
git commit -m 'SSL certificate is renewed until date'
git push origin HEAD:ssl-renewal # ssl-renewal can be your own remote branch
# Then send PR to the tech team.
```

Open a pull request in Github with your changes. The Simple team will accept your changes in a few days.

## Install/Update the SSL Certificates

In the meantime, you don't have to wait. You can immediately install the new certificate on Simple Server from the deployment repository.

```bash
make update-ssl-certs hosts=<deployment>   
```
For example
```
make update-ssl-certs hosts=ethiopia_production
```