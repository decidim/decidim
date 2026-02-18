<!-- markdownlint-disable-file link-fragments -->

## About the GraphQL API

[Decidim](https://github.com/decidim/decidim) comes with an API that follows the [GraphQL](https://graphql.org/) specification. It has a comprehensive coverage of all the public content that can be found on the website.

Currently, it is read-only (except for posting comments) but intends to cover anything that is published on the regular website.

Typically (although some particular installations may change that) you will find 3 relevant folders:

* `URL/api` The route where to make requests. Request are usually in the POST format.
* `URL/api/docs` This documentation, every Decidim site should provide one.
* `URL/api/graphiql` [GraphiQL](https://github.com/graphql/graphiql) is a in-browser IDE for exploring GraphQL APIs. Some Decidim installations may choose to remove access to this tool. In that case you can use a [standalone version](https://electronjs.org/apps/graphiql) and use any `URL/api` as the endpoint

### Using the GraphQL API

The GraphQL format is a JSON formatted text that is specified in a query. Response is a JSON object as well. For details about specification check the official [GraphQL site](https://graphql.org/learn/).

For additional examples of queries and mutations, check the additional [GraphQL API documentation](https://docs.decidim.org/en/develop/develop/api/index.html) of Decidim.

Exercise caution when utilizing the output of this API, as it may include HTML that has not been escaped. Take particular care in handling this data, specially if you intend to render it on a webpage.

For instance, you can check the version of a Decidim installation by using `curl` in the terminal:

```bash
curl -sSH "Content-Type: application/json" \
-d '{"query": "{ decidim { version } }"}' \
https://www.decidim.barcelona/api/
```

Note that `Content-Type` needs to be specified.

The query can also be used in GraphiQL, in that case you can skip the `"query"` text:

```graphql
{
  decidim {
    version
  }
}
```

Response (formatted) should look something like this:

```json
{
  "data": {
    "decidim": {
      "version": "0.18.1"
    }
  }
}
```

For additional examples of queries and mutations, check the additional [GraphQL API documentation](https://docs.decidim.org/en/develop/develop/api/index.html) of Decidim.
