import ApolloClient, { createNetworkInterface } from "apollo-client";

// Create a custom network interface for Apollo since our
// API endpoint is not the default.
const networkInterface = createNetworkInterface({
  uri: "/api",
  opts: {
    credentials: "same-origin",
  },
});

const client = new ApolloClient({
  networkInterface,
});

export default client;
