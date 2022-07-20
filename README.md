# Simple Standalone

An Ansible collection for running [Simple Server](https://github.com/simpledotorg/simple-server) on virtual machines.

[Overview of standalone architecture](docs/architecture.md)

## Getting Started

### Install local requirements
```bash
brew install rbenv
rbenv install 2.7.4
brew install ansible@2.8.3 gnu-tar
make init
```

### Add a new deployment

You can add a new deployment by running the following command.

```bash
$ bin/new
```

This script will prompt you for some key information about your new deployment:
* Deployment name
* Deployment domain/subdomain
* IP addresses of your servers

and generate the necessary files for you. Once complete, the script will provide you with instructions on how to install
Simple on your new servers.

#### Setup SSH on servers

You will need to setup SSH access to a remote user with [NOPASSWD](https://linuxhint.com/setup-sudo-no-password-linux/) sudo access on the servers.
We recommend using the username `ubuntu`. You can configure this to something else in [`ansible.cfg`](/standalone/ansible/ansible.cfg).
To setup this user, you can run this on each server:
```
$ adduser ubuntu
$ sudo visudo
# At the end of the file add
ubuntu     ALL=(ALL) NOPASSWD:ALL
```
Note: AWS ec2 instances already come with an `ubuntu` sudoer.

Setup your SSH keys on the server for the `ubuntu` user. Make sure you can establish an SSH connection to your server as `ubuntu`.

### Edit vault secrets

Secret configurations for your deployment (eg. database credentials, API tokens) are stored in the
`group_vars/<deployment>/vault.yml` file. This file is encrypted using [Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html).

To edit the secret configurations in the vault, run the command:

```bash
$ make edit-vault hosts=<deployment>
```

For example, to edit the Ethiopia Demo secrets, run

```bash
$ make edit-vault hosts=ethiopia_demo
```

This will automatically open your default text editor with the decrypted secrets. You can make any necessary changes,
save the file, and exit the editor. The encrypted vault file will automatically be updated with the new secrets, and you
can commit the changes.

#### More vault options

If you wish to keep a copy of the decrypted locally to work with, you can run

```bash
$ make decrypt hosts=<deployment>
```

This will create a `vault.yml.decrypted` file for you that you can work with. This file is git-ignored by default to
avoid committing and publishing secrets. To update secret configurations, you can make changes to the `.yml.decrypted`
file, and re-encrypt the vault file with:

```bash
$ make encrypt hosts=<deployment>
```

## Other Helpful Commands

### Making a deploy

You can deploy the latest updates to Simple to your servers with the following command

```bash
make deploy hosts=your_deployment_name
```
This deploys https://github.com/simpledotorg/simple-server/tree/master to all of your deployment's servers.

### Update SSH keys

To manage the authorized SSH keys that can access your servers,

First, add or remove the appropriate SSH keys from the `group_vars/<your deployment name>/vars.yml` file

Then, run the following command.

```bash
make update-ssh-keys hosts=your_deployment_name
```

This will deploy the updated list of SSH keys to your servers. Note that this clears any old keys present on the servers.

### Updating app configuration

Simple has several configuration options, some of which are sensitive. You can find all of Simple's configuration options
listed and documented in the following files.

* `group_vars/<your deployment name>/vars.yml`
* `group_vars/<your deployment name>/vault.yml` (see [Edit Vault Secrets](#edit-vault-secrets) to learn how to manage your vault)

To update the configuration of your deployment,

First, update the necessary configurations in your vars or vault file.

Next, run the following command.

```bash
make update-app-config hosts=your_deployment_name
```

This will deploy the updated configuration to your servers.

### Restarting Simple

You can restart the entire Simple application with the following command.

```bash
make restart hosts=your_deployment_name
```

This restarts Passenger and Sidekiq on all of your servers. You can also restart these services individually if you'd
like with the following commands.

```bash
make restart-passenger hosts=your_deployment_name
make restart-sidekiq hosts=your_deployment_name
```

## Developer notes and decisions

### Environment groups

In order to support the deployment of Simple to multiple countries, we need a mechanism to allow for setting per-country
Ansible variables. Traditionally, all country servers would be placed in a single inventory file, with groups for each
country. However, since different teams may be managing each country, we have chosen to split each deployment target
into its own inventory file.

In order to support per-inventory variables, we assign a uniquely named group in each inventory that covers all servers
in the inventory. For example, we create an `ethiopia_production` group that covers all servers in the
`ethiopia_production` inventory file.

This allows us to centralize the configuration for each deployment target into a single location - `group_vars/<target>`

### Vault ID labels

Ansible supports the assignment of labels to different vault password files. It also allows the label (known as a vault
ID) to be stored in the header of the encrypted vault file. This allows Ansible to automatically select a vault password
when decrypting vault files. We use the vault ID feature to simplify vault management in this repository. The following
touchpoints are involved:

* `ansible.cfg`: A full list of vault IDs per deployment is declared in the Ansible config file
* Vault passwords: Vault passwords will need to be stored in the developer's home directory with the appropriate
  filename, as declared in the `ansible.cfg`
* Makefile: The Makefile includes tasks to edit, decrypt, and encrypt vault files. Since we leverage the convention of
  vault labels, the only option that needs to be passed to these commands is the deployment name.
  * `edit-vault`
  * `decrypt`
  * `encrypt`
  * Example: `make edit-vault hosts=ethiopia_demo`

## Local setup for testing with Vagrant

### Prerequisite
- [Vagrant](https://www.vagrantup.com/)
- [Virtualbox](https://www.virtualbox.org/)
- Get Ansible vault secret from simple server team

### Setup
- `cd` into Vagrant folder `cd vagrant`
- Provision Vagrant nodes `vagrant up`. Note: First time setup might take a while, depending on your internet speed
- Add user and ssh keys, [follow](#setup-ssh-on-servers). Use `vagrant ssh node-01` and `vagrant ssh node-02` commands to ssh into the nodes
- Install Ansible prerequisites `make init`
- If required add Ansible vault secret key to file `echo '<secret>' > ~/.vault_password_et`
- Apply Ansible roles `make all hosts=local`
- Add hostname entry `echo '10.10.10.113 simple.example.com' | sudo tee -a /etc/hosts`
- Validate the installation by opening https://simple.example.com, ignore the ssl warning and proceed to advanced

### Destroy
- `cd` into Vagrant folder `cd vagrant`
- Destroy Vagrant nodes `vagrant destroy -f`
