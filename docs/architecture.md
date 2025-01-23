## Simple Standalone Architecture

### Components

The Simple Server setup managed by this tooling has the following components.

| Component                          | Purpose                                               | Technologies                                           |
| ---------                          | -------                                               | ------------                                           |
| Primary relational database        | Primary application database                          | [PostgreSQL][1]                                        |
| Secondary relational database      | Follower application database                         | [PostgreSQL][1]                                        |
| Primary non-relational datastore   | Datastore for application caching and background jobs | [Redis][2]                                             |
| Secondary non-relational datastore | Follower for primary non-relational datastore         | [Redis][2]                                             |
| Web servers                        | Dashboard web application and APIs                    | [Ruby on Rails][3]<br>[Passenger][4]<br>[Metabase][10] |
| Background processing servers      | Perform enqueued tasks asynchronously                 | [Sidekiq][9]                                           |
| Load balancer                      | Route incoming web requests across web servers        | [HAProxy][5]                                           |
| System health monitoring           | Monitor the system health of all Simple servers       | [Prometheus][6]<br>[Grafana][8]                        |
| Storage                            | Large storage location for logs and database backups  | [`rsync`][7]                                           |

### Topography

These components are arranged in the following topography.

```
                                                         ┌────────────────┐
                                                         │    replica     │
                                                         │ non-relational │
                                                         │     store      │
                                                         └────────────────┘
                                                                 │
                                                                 │
                                    ┌─────────┐                  │                     ┌────────────┐
                  ┌──────────┐     ┌─────────┐│          ┌────────────────┐           ┌────────────┐│
    incoming      │   load   │     │   web   ││          │    primary     │           │ background ││
    requests  ─── │ balancer │ ─── │ servers ││ ─┬────── │ non-relational │ ──────┬── │ processors ││
                  │          │     │         │┘  │       │     store      │       │   │            │┘
       │          └──────────┘     └─────────┘   │       └────────────────┘       │   └────────────┘
       │                                         │                                │
       │                                │        │       ┌────────────────┐       │
┌────────────┐                          │        │       │    primary     │       │
│   system   │                          │        │       │   relational   │       │
│ monitoring │                          │        └────── │     store      │ ──────┘
│            │                          │                └────────────────┘
└────────────┘                          │                        │
                                     ┌──────┐                    │
                                     │ logs │                    │
                                     └──────┘            ┌────────────────┐
                                                         │    replica     │
                                                         │   relational   │
                                                         │     store      │
                                                         └────────────────┘
```

  [1]: https://www.postgresql.org/
  [2]: https://redis.io/
  [3]: https://rubyonrails.org/
  [4]: https://www.phusionpassenger.com/
  [5]: http://www.haproxy.org/
  [6]: https://prometheus.io/
  [7]: https://linux.die.net/man/1/rsync
  [8]: https://grafana.com/ 
  [9]: https://github.com/mperham/sidekiq
  [10]: https://metabase.com/
