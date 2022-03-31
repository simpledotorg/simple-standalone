# Simple Standalone

An Ansible collection for running [Simple Server](https://github.com/simpledotorg/simple-server) on virtual machines.

## Getting Started

### Add a new deployment

Coming soon...

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
