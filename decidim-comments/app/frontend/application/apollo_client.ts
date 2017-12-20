import { InMemoryCache } from "apollo-cache-inmemory";
import { ApolloClient } from "apollo-client";
import { createHttpLink } from "apollo-link-http";

import "unfetch/polyfill";

// Create a custom network interface for Apollo since our
// API endpoint is not the default.
const httpLink = createHttpLink({
  uri: "/api",
  fetch,
  credentials: "same-origin",
});

const client = new ApolloClient({
  link: httpLink,
  cache: new InMemoryCache(),
});

export default client;
