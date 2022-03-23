# Simple Standalone

An Ansible collection for running [Simple Server](https://github.com/simpledotorg/simple-server) on virtual machines.

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
