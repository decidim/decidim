## About the GraphQL APi

[Decidim](https://github.com/decidim/decidim) comes with an API that follows the [GraphQL](https://graphql.org/) specification. It has a comprehensive coverage of all the public content that can be found on the website.

Currently, it is read-only (except for posting comments) and does not.

Typically (although some particular installations may change that) you will find 3 relevant folders:

* `URL/api` The route where to make requests. Request are usually in the POST format.
* `URL/api/docs` This documentation, every Decidim site should provide one.
* `URL/api/graphiql` [GraphiQL](https://github.com/graphql/graphiql) is a in-browser IDE for exploring GraphQL APIs. Some Decidim installations may choose to remove access to this tool. In that case you can use a [standalone version](https://electronjs.org/apps/graphiql) and use any `URL/api` as the endpoint

### Using the GraphQL APi

The GraphQL format is a JSON formatted text that is specified in a query. Response is a JSON object as well. For details about specification check the official [GraphQL site](https://graphql.org/learn/).

For instance, you can check the version of a Decidim installation by using `curl` in the terminal:

```
curl -sSH "Content-Type: application/json" \
-d '{"query": "{ decidim { version } }"}' \
https://www.decidim.barcelona/api/
```

Note that `Content-Type` needs to be specified.

The query can also be used in GraphiQL, in that case you can skip the `"query"` text:

```
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

The most practical way to experiment with GraphQL, however, is just to use the in-browser IDE GraphiQL. It provides access to the documentation and auto-complete (use CTRL-Space) for writing queries.

### Usage limits

Decidim is just a Rails application, meaning that any particular installation may implement custom limits in order to access the API (and the application in general).

By default (particular installations may change that), API uses the same limitations as the whole Decidim website, provided by the Gem [Rack::Attack](https://github.com/kickstarter/rack-attack). These are 100 maximum requests per minute per IP to prevent DoS attacks

### Decidim structure, Types, collections and Polymorphism

There are no endpoints in the GraphQL specification, instead objects are organized according to their "Type".

These objects can be grouped in a single, complex query. Also, objects may accept parameters, which are "Types" as well.

Each "Type" is just a pre-defined structure with fields, or just an Scalar (Strings, Integers, Booleans, ...).

For instance, to obtain *all the participatory processes in a Decidim installation published since January 2018* and order them by published date, we could execute the next query:

```
{
  participatoryProcesses(filter: {publishedSince: "2018-01-01"}, order: {publishedAt: "asc"}) {
    slug
    title {
      translation(locale: "en")
    }
  }
}
```

Response should look like:

```
{
  "data": {
    "participatoryProcesses": [
      {
        "slug": "consectetur-at",
        "title": {
          "translation": "Soluta consectetur quos fugit aut."
        }
      },
      {
        "slug": "nostrum-earum",
        "title": {
          "translation": "Porro hic ipsam cupiditate reiciendis."
        }
      }
    ]
  }
}
```

#### What happened?

In the former query, each represents a type, the words `publishedSince`, `publishedAt`, `slug`, `locale` are scalars, all of them Strings.

The other however, are objects representing certain entities:

- `participatoryProcesses` is a type that represents a collection of participatory spaces. It accepts arguments (`filter` and `order`), which are other object types as well. `slug` and `title` are the fields of the participatory process we are interested in, there are "Types" too.
- `filter` is a [ParticipatoryProcessFilter](#ParticipatoryProcessFilter) input type, it has several properties that allows us to refine our search. One of the is the `publishedSince` property with the initial date from which to list entries.
- `order ` is a [ParticipatoryProcessSort](#ParticipatoryProcessSort) type, works the same way as the filter but with the goal of ordering the results.
- `title` is a [TranslatedField](#TranslatedField) type, which allows us to deal with multi-language fields.

Finally, note that the returned object is an array, each item of which is a representation of the object we requested.

#### Decidim main types

Decidim has 2 main types of objects through which content is provided. These are Participatory Spaces and Components.

A participatory space is the first level, currently there are 5 officially supported: *Participatory Processes*, *Assemblies*, *Consultations*, *Conferences* and *Initiatives*. For each participatory process there will correspond collection type and "single item" type.

The previous example uses the collection type for participatory processes. You can try `assemblies`, `conferences`, `consultations` or `initiatives` for the others. Note that each collection can implement their own filter and order types with different properties.

As an example for a single item query, you can run:

```
{
  participatoryProcess(slug:"consectetur-at") {
    slug
    title {
      translation(locale: "en")
    }
  }
}
```

And the response will be:

```
{
  "data": {
    "participatoryProcess": {
      "slug": "consectetur-at",
      "title": {
        "translation": "Soluta consectetur quos fugit aut."
      }
    }
  }
}
```

#### What's different?

First, note that we are querying, in singular, the type `participatoryProcess`, with a different parameter, `slug`\*, this time a String. We can use the `id` instead if we know it.

Second, the response is not an Array, it is just the object we requested. We can expect to return `null` if the object is not found.

> \* The `slug` is a convenient way to find a participatory space as is (usually) in the url.
>
> For instance, consider this real case from Barcelona:
>
> https://www.decidim.barcelona/processes/patrimonigracia
>
> The word `patrimonigracia` indicates the "slug".

#### Components

Every participatory space may (and should) have some components. There are 9 official components, these are `Proposals`, `Page`, `Meetings`, `Budgets`, `Surveys`, `Accountability`, `Debates`, `Sortitions` and `Blog`. Plugins may add they own components.

If you know the `id`\* of a specific component you can obtain it by querying it directly:

```
{
  component(id:2) {
    id
    name {
      translation(locale:"en")
    }
    __typename
    participatorySpace {
      id
      type
    }
  }
}
```

Response:

```
{
  "data": {
    "component": {
      "id": "2",
      "name": {
        "translation": "Meetings"
      },
      "__typename": "Meetings",
      "participatorySpace": {
        "id": "1",
        "type": "Decidim::ParticipatoryProcess"
      }
    }
  }
}
```

The process is analogue as what has been explained in the case of searching for one specific participatory process.

> \*Note that the `id` of a component is present also in the url after the letter "f":
>
> https://www.decidim.barcelona/processes/patrimonigracia/f/3257/
>
> In this case, 3257.

#### What about component's collections?

Glad you asked, components collections cannot be retrieved directly, the are available *in the context* of a participatory space.

For instance, we can query all the components in an particular Assembly as follows:

```
{
  assembly(id: 3) {
    components {
      id
      name {
        translation(locale: "en")
      }
      __typename
    }
  }
}
```

The response will be similar to:

```
{
  "data": {
    "assembly": {
      "components": [
        {
          "id": "42",
          "name": {
            "translation": "Accountability"
          },
          "__typename": "Component"
        },
        {
          "id": "38",
          "name": {
            "translation": "Meetings"
          },
          "__typename": "Meetings"
        },
        {
          "id": "37",
          "name": {
            "translation": "Page"
          },
          "__typename": "Pages"
        },
        {
          "id": "39",
          "name": {
            "translation": "Proposals"
          },
          "__typename": "Proposals"
        }
      ]
    }
  }
}
```

We can also apply some filters by using the [BareComponentFilter](#BareComponentFilter) type. In the next query we would like to *find all the components with geolocation enabled in the assembly with id=2*:

```
{
  assembly(id: 3) {
    components(filter: {withGeolocationEnabled: true}) {
      id
      name {
        translation(locale: "en")
      }
      __typename
    }
  }
}
```

The response:

```
{
  "data": {
    "assembly": {
      "components": [
        {
          "id": "38",
          "name": {
            "translation": "Meetings"
          },
          "__typename": "Meetings"
        }
      ]
    }
  }
}
```

Note that, in this case, there's only one component returned, "Meetings". In some cases Proposals can be geolocated too.

### Polymorphism

...
