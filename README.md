# fb-user-datastore
User Data store API for services built &amp; deployed on Form Builder


# Environment Variables

The following environment variables are either needed, or read if present:

* DATABASE_URL: used to connect to the database
* RAILS_ENV: 'development' or 'production'
* REDIS_URL or REDISCLOUD_URL: if either of these are present, cache tokens in
  Redis at this URL rather than in local files (default)
* FB_ENVIRONMENT_SLUG: 'dev', 'staging', or 'production' - which Form Builder
  environment is this running in? This will affect the suffix of the K8s
  secrets & namespaces it will try to read service tokens from
* KUBECTL_BEARER_TOKEN: identifies the ServiceAccount the app will authenticate
  against in kubernetes for kubectl calls
* KUBECTL_CONTEXT: (optional) which kubectl context it will look for secrets in
* SERVICE_TOKEN_CACHE_TTL: expire service token cache entries after this many
  seconds

## To deploy and run on Cloud Platforms

See [deployment instructions](DEPLOY.md)
