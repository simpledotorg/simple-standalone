# Simple Standalone

An Ansible collection for running [Simple Server](https://github.com/simpledotorg/simple-server) on virtual machines.

## Getting Started

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
