## Simple Standalone Architecture

### Components

The Simple Server setup managed by this tooling has the following components.

| Component                          | Purpose | Technologies |
| ---------                          | ------- | ------------ |
| Primary relational database        | Primary application database | [PostgreSQL](https://www.postgresql.org/) |
| Secondary relational database      | Follower application database | [PostgreSQL](https://www.postgresql.org/) |
| Primary non-relational datastore   | Datastore for application caching and background jobs | [Redis](https://redis.io/) |
| Secondary non-relational datastore | Follower for primary non-relational datastore | [Redis](https://redis.io/) |
| Web servers                        | Dashboard web application and APIs | [Ruby on Rails](https://rubyonrails.org/)<br>[Passenger](https://www.phusionpassenger.com/) |
| Background processing servers      | Perform enqueued tasks asynchronously | [Sidekiq](https://github.com/mperham/sidekiq) |
| Load balancer                      | Route incoming web requests across web servers | [HAProxy](http://www.haproxy.org/) |
| System health monitoring           | Monitor the system health of all Simple servers | [Prometheus](https://prometheus.io/)<br>[Grafana](https://grafana.com/) |
| Storage                            | Large storage location for logs and database backups | [`rsync`](https://linux.die.net/man/1/rsync) |

### Topography

These components are arranged in the following topography.

![topography](https://docs.google.com/drawings/d/e/2PACX-1vTr2ryR_vqxAtdNCzKxn1pIdz3b57be8j3iHAVBEDBGstA6jGqOX6deyoXeWBXEk_yzeybFsmrzm5Ww/pub?w=960&amp;h=720)

If this image is out-of-date, you can edit it [here](https://docs.google.com/drawings/d/1jHZeW141ivRUAWhHEduwlyasFxNzZ1Nk2V_AQ12w4p8/edit).
