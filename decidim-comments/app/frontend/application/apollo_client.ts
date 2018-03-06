import { InMemoryCache } from "apollo-cache-inmemory";
import { ApolloClient } from "apollo-client";
import { HttpLink } from "apollo-link-http";

import "unfetch/polyfill";

const client = new ApolloClient({
  link: new HttpLink({ uri: "/api", credentials: "same-origin", fetch }),
  cache: new InMemoryCache()
});

export default client;
