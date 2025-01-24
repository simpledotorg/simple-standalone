# Infrastructure

##### IP Addresses

The two Ethiopia production servers are accessible through public IP addresses as well as internal IP addresses if you
are in the network.

When managing the production servers from outside the internal network, the [`production`](../standalone/hosts/ethiopia/production)
hosts file should be used with `make`/`ansible` commands.

```
                     ┌−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−┐
                     ╎ cluster-1                              ╎
                     ╎                                        ╎
  ┌──────────┐       ╎ ┌────────┐          ┌────────────────┐ ╎
  │ incoming │       ╎ │  LB 1  │          │ server-cluster │ ╎
  │ requests │   ─── ╎ │        │ ───┬──── │       1        │ ╎
  └──────────┘       ╎ └────────┘    │     └────────────────┘ ╎
                     ╎               │                        ╎
                     └−−−−−−−−−−−−−−−+−−−−−−−−−−−−−−−−−−−−−−−−┘
                     ┌−−−−−−−−−−−−−−−+−−−−−−−−−−−−−−−−−−−−−−−−┐
                     ╎ cluster-2     │                        ╎
                     ╎               │                        ╎
                     ╎ ┌────────┐    │     ┌────────────────┐ ╎
                     ╎ │  LB 2  │    │     │ server-cluster │ ╎
                     ╎ │(unused)│    └──── │       2        │ ╎
                     ╎ └────────┘          └────────────────┘ ╎
                     ╎                                        ╎
                     └−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−┘
```

##### Load balancing:
- Both instances run an instance of HAProxy. The ET URL currently points to `cluster-1`. The `LB 2`
is for redundancy and is not pointed to by a DNS. It is however configured to talk to the webservers already.

##### Web server and sidekiq:
- Both boxes run an instance of the Rails webserver and sidekiq (for background job processing). At all times, these services need to talk to:
    - Primary Postgres DB
    - Redis

##### Postgres:
- Both boxes run an instance of postgres. Postgres on `cluster-1` is the primary database. `cluster-2` is a hot standby, which can be
  quickly promoted to primary in a contingency.

##### Logs:

All logs are shipped to `cluster-2`. DB backups are periodically shipped to Box 2 as well.

#### If `cluster-1` dies

- Promote postgres replica on `cluster-2` to become master; Change rails config to talk to postgres on `cluster-2`.
    - (TODO: Add steps/commands here)
- Update Rails and Sidekiq config to talk to redis on `cluster-2`.
- Setup monitoring daemons (grafana, prometheus) to run on `cluster-2`.
- Point the ET URL DNS in cloudflare to `cluster-2`.

#### If `cluster-2` dies
- Nothing critical is affected, `simple-server` will continue to run smoothly. Postgres replication, logshipping will stop.
