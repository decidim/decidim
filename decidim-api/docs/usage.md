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

The most practical way to experiment with GraphQL, however, is just to use the in-browser IDE GraphiQL. It provides access to the documentation and auto-complete (use CTRL-Space) for writing queries.

From now on, we will skip the "query" keyword for the purpose of readability. You can skip it too if you are using GraphiQL, if you are querying directly (by using CURL for instance) you will need to include it.

### Signing in to the API

In case you want to use the API as a sign in user to perform mutations representing a user in Decidim, you have two available options for such integrations through the system administration panel:

1. Creating an OAuth application and implementing the OAuth authentication flow for the users of your application. Use this option for participant-facing applications where the participants represent themselves in Decidim through the API.
2. Creating API credentials and signing in to the API with these credentials to perform the operations as a signed in machine user. Use this option for machine-to-machine automations where there is no real end user interacting with Decidim.

If you only want to test the GraphQL queries as a signed in user, you can use the normal Decidim authentication functionality to sign in and then use the GraphiQL IDE to perform these queries as a signed in user.

#### OAuth flow for participant-facing applications

Participant-facing applications where the participants need to interact with Decidim through GraphQL mutations can be integrated using OAuth applications. In order to configure such integration capability from the system administration panel, create a new OAuth application and provide the necessary details for your integration. Note that the "application type" for such applications would typically be "Public". For more information regarding the application types, refer to [RFC 6749 Section 2.1. (OAuth client types)](https://datatracker.ietf.org/doc/html/rfc6749#section-2.1).

In order to use the OAuth access tokens to represent the user through the API, please select the following scopes as "Available" scopes for the application:

- `user` - Authenticated users have the ability to represent a logged in user in Decidim
- `api:read` - Authenticated users have the ability to read data from the API
- `api:write` - Authenticated users have the ability to write data through the API (in case your external application needs to perform mutations over the API on behalf of the user)

Once configured, you can now use any OAuth authentication library to perform the OAuth authentication flow with your application users and receive an access token to utilize the Decidim API representing the signed in user. Please note that with public OAuth clients especially (and recommended also for confidential clients), you have to use [PKCE](https://datatracker.ietf.org/doc/html/rfc7636) with the authorization flow.

Once the OAuth application is created, you can authenticate against it with the following steps:

1. Send the user to perform an OAuth authorization request at Decidim with the required API scopes (`user`, `api:read` and `api:write` if you want to perform mutations over the API). Along with the authorization request, also send the additional parameters required by PKCE (`code_challenge` and `code_challenge_method`).
2. Receive an OAuth authorization code back to your application's configured redirect URI.
3. Utilizing the received authorization code, request an OAuth access token from the OAuth token endpoint. Along with the token request, also send the additional parameter required by PKCE `code_verifier`.
4. The issued token is a JSON Web Token (JWT) when the authorization request contains the defined scopes. This token can be now used to represent the user in further calls to the API by passing the token with its type (`Bearer`) within the HTTP Authorization header with the request to the API.

When doing the requests to the API, you also need to pass the OAuth client ID within the `X-Jwt-Aud` header of the requests in order for the token to be recognized as a valid token for the issued client. Passing the bearer token to the `Authorization` header and the OAuth client ID to the `X-Jwt-Aud` header, you can send the following HTTP request to the API to validate that the token works and the user is recognized as signed in:

```
POST /api HTTP/1.1
Accept: application/json
Authorization: Bearer token
Content-Length: 53
Content-Type: application/json
Host: DOMAIN
X-Jwt-Aud: OAUTH_CLIENT_ID

{"query":"{ session { user { id name nickname } } }"}
```

You should see the user details in the response in case the token is valid and you have configured the API correctly. If the response does not contain the user details, please refer to the Decidim configuration documentation.

Once the interaction with the API is completed, it is recommended to revoke the tokens, which is similar to the user signing out of the application. This can be done utilizing the OAuth revocation endpoint provided by Decidim. After the token is revoked, it is no longer valid and the user has to perform a re-authorization the next time they want to utilize the API.

In case you need tokens with a longer life span, you can either look into the Decidim documentation to extend the validity period of the access tokens or enable refresh tokens for the OAuth application when configuring it. However, note that tokens with longer lifespan can weaken the security of your system and make your application users vulnerable to security threats. Such use cases should be carefully planned and the security concerns should be addressed seriously.

#### API credentials flow for machine-to-machine automations

The API credentials represent an administrative user in Decidim that performs administrative tasks on behalf of the end users. This type of integration flows should never live on devices that the participants have access to. These types of integrations are meant for different types of automations, such as transferring proposal answers or meeting reports back to Decidim from an external system automatically, e.g. once a day.

Note that these credentials are highly sensitive and have elevated permissions, so take good care of the system security where you are planning to store these credentials. If these credentials end up in participants' hands, the whole system is compromised and no longer secure. You should always primarily create OAuth integrations where the end users will manually perform the authorization for the application to perform actions on behalf of them.

Once you have validated that this is the correct way for your integration to operate, you can create the API credentials from the system administration panel. You will receive an API key and API secret after creating the credentials. These credentials should be also manually rotated on a regular basis to prevent unauthorized access to the system with these credentials in case they are leaked. The credentials have to be manually rotated in order to prevent external applications breaking because they cannot rotate the credentials themselves and they are typically statically configured for these applications.

Given you have issued the API key and API secret, you can now send a sign in request to the API using these credentials as follows:

```bash
curl -s -i -H "Content-type: application/x-www-form-urlencoded" \
  -d "api_user[key]=PASTE_API_KEY_HERE" \
  -d "api_user[secret]=PASTE_API_SECRET_HERE" \
  -X POST https://DOMAIN/api/sign_in | grep 'Authorization' | cut -d ' ' -f2-
```

After running this command, you should see the following string in the console, where `token` is replaced with the access token:

```
Bearer token
```

This string is passed to the following requests within the HTTP `Authorization` header to represent the user during API calls. You can use the following example query to test it out and confirm that signing in works as expected:

```bash
curl -w "\n" -H "Content-Type: application/json" \
  -H "Authorization: Bearer token" \
  -d '{"query":"{ session { user { id name nickname } } }"}' \
  -X POST https://DOMAIN/api
```

You should see the user details in the response in case the token is valid and you have configured the API correctly. If the response does not contain the user details, please refer to the Decidim configuration documentation.

Once the API interaction is done, you should always make an HTTP DELETE request to `/api/sign_out` with the same token in order to revoke the token from further access as follows:

```bash
curl -s -o /dev/null -w "HTTP %{http_code}\n" \
  -H "Authorization: Bearer token" \
  -X DELETE http://localhost:3000/api/sign_out
```

### Usage limits

Decidim is just a Rails application, meaning that any particular installation may implement custom limits in order to access the API (and the application in general).

By default (particular installations may change that), API uses the same limitations as the whole Decidim website, provided by the Gem [Rack::Attack](https://github.com/kickstarter/rack-attack). These are 100 maximum requests per minute per IP to prevent DoS attacks

### Decidim structure, Types, collections and Polymorphism

There are no endpoints in the GraphQL specification, instead objects are organized according to their "Type".

These objects can be grouped in a single, complex query. Also, objects may accept parameters, which are "Types" as well.

Each "Type" is just a pre-defined structure with fields, or just an Scalar (Strings, Integers, Booleans, ...).

For instance, to obtain *all the participatory processes in a Decidim installation published since January 2018* and order them by published date, we could execute the next query:

```graphql
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

```json
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

In the former query, each keyword represents a type, the words `publishedSince`, `publishedAt`, `slug`, `locale` are scalars, all of them Strings.

The other keywords however, are objects representing certain entities:

* `participatoryProcesses` is a type that represents a collection of participatory spaces. It accepts arguments (`filter` and `order`), which are other object types as well. `slug` and `title` are the fields of the participatory process we are interested in, there are "Types" too.
* `filter` is a [ParticipatoryProcessFilter](#ParticipatoryProcessFilter)\* input type, it has several properties that allows us to refine our search. One of them is the `publishedSince` property with the initial date from which to list entries.
* `order` is a [ParticipatoryProcessSort](#ParticipatoryProcessSort) type, works the same way as the filter but with the goal of ordering the results.
* `title` is a [TranslatedField](#TranslatedField) type, which allows us to deal with multi-language fields.

Finally, note that the returned object is an array, each item of which is a representation of the object we requested.

> \***About how filters and sorting are organized**
>
> There are two types of objects to filter and ordering collections in Decidim, they all work in a similar fashion. The type involved in filtering always have the suffix "Filter", for ordering it has the suffix "Sort".
>
> The types used to filter participatory spaces are: [ParticipatoryProcessFilter](#ParticipatoryProcessFilter), [AssemblyFilter](#AssemblyFilter), and so on.
>
> Other collections (or connections) may have their own filters (i.e. [ComponentFilter](#ComponentFilter)).
>
> Each filter has its own properties, you should check any object in particular for details. The way they work with multi-languages fields, however, is the same:
>
> We can say we have some searchable object with a multi-language field called *title*, and we have a filter that allows us to search through this field. How should it work? Should we look up content for every language in the field? or should we stick to a specific language?
>
> In our case, we have decided to search only one particular language of a multi-language field but we let you choose which language to search.
> If no language is specified, the configured as default in the organization will be used. The keyword to specify the language is `locale`, and it should be provided in the 2 letters ISO 639-1 format (en = English, es = Spanish, ...).
>
> Example (this is not a real Decidim query):
>
> ```graphql
>  some_collection(filter: { locale: "en", title: "ideas"}) {
>    id
>  }
> ```
>
> The same applies to sorting ([ParticipatoryProcessSort](#ParticipatoryProcessSort), [AssemblySort](#AssemblySort), etc.)
>
> In this case, the content of the field (*title*) only allows 2 values: *ASC* and *DESC*.
>
> Example of ordering alphabetically by the title content in French language:
>
> ```graphql
> some_collection(order: { locale: "en", title: "asc"}) {
>   id
> }
> ```
>
> Of course, you can combine both filter and order. Also remember to check availability of this type of behaviour for any particular filter/sort.

#### Decidim main types

Decidim has 2 main types of objects through which content is provided. These are Participatory Spaces and Components.

A participatory space is the first level, currently there are 5 officially supported: *Participatory Processes*, *Assemblies*, *Conferences* and *Initiatives*. For each participatory process there will correspond a collection type and a "single item" type.

The previous example uses the collection type for participatory processes. You can try `assemblies`, `conferences`, or `initiatives` for the others. Note that each collection can implement their own filter and order types with different properties.

As an example for a single item query, you can run:

```graphql
{
  participatoryProcess(slug: "consectetur-at") {
    slug
    title {
      translation(locale: "en")
    }
  }
}
```

And the response will be:

```json
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

#### What is different?

First, note that we are querying, in singular, the type `participatoryProcess`, with a different parameter, `slug`\*, (a String). We can use the `id` instead if we know it.

Second, the response is not an Array, it is just the object we requested. We can expect to return `null` if the object is not found.

> \* The `slug` is a convenient way to find a participatory space as is (usually) in the URL.
>
> For instance, consider this real case from Barcelona:
>
> https://www.decidim.barcelona/processes/patrimonigracia
>
> The word `patrimonigracia` indicates the "slug".

#### Components

Every participatory space may (and should) have some components. There are 9 official components, these are `Proposals`, `Page`, `Meetings`, `Budgets`, `Surveys`, `Accountability`, `Debates`, `Sortitions` and `Blog`. Plugins may add their own components.

If you know the `id`\* of a specific component you can obtain it by querying it directly:

```graphql
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

```json
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

> \*Note that the `id` of a component is present also in the URL after the letter "f":
>
> https://www.decidim.barcelona/processes/patrimonigracia/f/3257/
>
> In this case, 3257.

##### What about component's collections?

Glad you asked, component's collections cannot be retrieved directly, the are available *in the context* of a participatory space.

For instance, we can query all the components in an particular Assembly as follows:

```graphql
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

```json
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

We can also apply some filters by using the [ComponentFilter](#ComponentFilter) type. In the next query we would like to *find all the components with geolocation enabled in the assembly with id=2*:

```graphql
{
  assembly(id: 2) {
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

```json
{
  "data": {
    "assembly": {
      "components": [
        {
          "id": "39",
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

Note that, in this case, there is only one component returned, "Meetings". In some cases Proposals can be geolocated too therefore would be returned in this query.

### Polymorphism and connections

Many relationships between tables in Decidim are polymorphic, this means that the related object can belong to different classes and share just a few properties in common.

For instance, components in a participatory space are polymorphic, while the concept of component is generic and all of them share properties like *published date*, *name* or *weight*, they differ in the rest. *Proposals* have the *status* field while *Meetings* have an *agenda*.

Another example are the case of linked resources, these are properties that may link objects of different nature between components or participatory spaces.

In a very simplified way (to know more please refer to the official guide), GraphQL polymorphism is handled through the operator `... on`. You will know when a field is polymorphic because the property `__typename`, which tells you the type of that particular object, will change accordingly.

In the previous examples we have queried for this property:

Response fragment:

```json
      "components": [
        {
          "id": "38",
          "name": {
            "translation": "Meetings"
          },
          "__typename": "Meetings"
        }
```

So, if we want to access the rest of the properties in a polymorphic object, we should do it through the `... on` operator as follows:

```graphql
{
  assembly(id: 2) {
    components {
      id
      ... on Proposals {

      }
    }
  }
}
```

Consider this query:

```graphql
{
  assembly(id: 3) {
    components(filter: {type: "Proposals"}) {
      id
      name {
        translation(locale: "en")
      }
      ... on Proposals {
        proposals(order: {likeCount: "desc"}, first: 2) {
          edges {
            node {
              id
              likes {
                name
              }
            }
          }
        }
      }
    }
  }
}
```

The response:

```json
{
  "data": {
    "assembly": {
      "components": [
        {
          "id": "39",
          "name": {
            "translation": "Proposals"
          },
          "proposals": {
            "edges": [
              {
                "node": {
                  "id": "35",
                  "likes": [
                    {
                      "name": "Ms. Johnathon Schaefer"
                    },
                    {
                      "name": "Linwood Lakin PhD 3 4 endr1"
                    },
                    {
                      "name": "Gracie Emmerich"
                    },
                    {
                      "name": "Randall Rath 3 4 endr3"
                    },
                    {
                      "name": "Jolene Schmitt MD"
                    },
                    {
                      "name": "Clarence Hammes IV 3 4 endr5"
                    },
                    {
                      "name": "Omar Mayer"
                    },
                    {
                      "name": "Raymundo Jaskolski 3 4 endr7"
                    }
                  ]
                }
              },
              {
                "node": {
                  "id": "33",
                  "likes": [
                    {
                      "name": "Spring Brakus"
                    },
                    {
                      "name": "Reiko Simonis IV 3 2 endr1"
                    },
                    {
                      "name": "Dr. Jim Denesik"
                    },
                    {
                      "name": "Dr. Mack Schoen 3 2 endr3"
                    }
                  ]
                }
              }
            ]
          }
        }
      ]
    }
  }
}
```

#### What is going on?

Until the `... on Proposals` line, there is nothing new. We are requesting the *Assembly* participatory space identified by the `id=3`, then listing all its components with the type "Proposals". All the components share the *id* and *name* properties, so we can just add them at the query.

After that, we want content specific from the *Proposals* type. In order to do that we must tell the server that the content we will request shall only be executed if the types matches *Proposals*. We do that by wrapping the rest of the query in the `... on Proposals` clause.

The next line is just a property of the type *Proposals* which is a type of collection called a "connection". A connection works similar as normal collection (such as *components*) but it can handle more complex cases.

Typically, a connection is used to paginate long results, for this purpose the results are not directly available but encapsulated inside the list *edges* in several *node* results. Also there are more arguments available in order to navigate between pages. This are the arguments:

* `first`: Returns the first *n* elements from the list
* `after`: Returns the elements in the list that come after the specified *cursor*
* `last`: Returns the last *n* elements from the list
* `before`: Returns the elements in the list that come before the specified *cursor*

Example:

```graphql
{
  assembly(id: 3) {
    components(filter: {type: "Proposals"}) {
      id
      name {
        translation(locale: "en")
      }
      ... on Proposals {
        proposals(first:2,after:"Mg") {
          pageInfo {
            endCursor
            startCursor
            hasPreviousPage
            hasNextPage
          }
          edges {
            node {
              id
              likes {
                name
              }
            }
          }
        }
      }
    }
  }
}
```

Being the response:

```json
{
  "data": {
    "assembly": {
      "components": [
        {
          "id": "39",
          "name": {
            "translation": "Proposals"
          },
          "proposals": {
            "pageInfo": {
              "endCursor": "NA",
              "startCursor": "Mw",
              "hasPreviousPage": false,
              "hasNextPage": true
            },
            "edges": [
              {
                "node": {
                  "id": "32",
                  "likes": []
                }
              },
              {
                "node": {
                  "id": "31",
                  "likes": [
                    {
                      "name": "Mr. Nicolas Raynor"
                    },
                    {
                      "name": "Gerry Fritsch PhD 3 1 endr1"
                    }
                  ]
                }
              }
            ]
          }
        }
      ]
    }
  }
}
```

As you can see, a part from the *edges* list, you can access to the object *pageInfo* which gives you the information needed to navigate through the different pages.

For more info on how connections work, you can check the official guide:

https://graphql.org/learn/pagination/
