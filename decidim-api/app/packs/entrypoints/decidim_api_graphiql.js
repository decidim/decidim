/* eslint-disable require-jsdoc */

import "entrypoints/decidim_api_graphiql.scss";
// Styles from node_modules/graphiql/graphiql.css
// It needs to be done in JS because postcss-import doesn't find files in node_modules/
import "graphiql/graphiql.css"

import React from "react";
import ReactDOM from "react-dom";

import GraphiQL from "graphiql";
import Configuration from "src/decidim/configuration"

window.Decidim = window.Decidim || {};
window.Decidim.config = new Configuration()

let parameters = {};

// Parse the search string to get url parameters.
const search = window.location.search;
search.substr(1).split("&").forEach(function (entry) {
  let eq = entry.indexOf("=");
  if (eq >= 0) {
    parameters[decodeURIComponent(entry.slice(0, eq))] =
      decodeURIComponent(entry.slice(eq + 1));
  }
});
// if variables was provided, try to format it.
if (parameters.variables) {
  try {
    parameters.variables =
      JSON.stringify(JSON.parse(parameters.variables), null, 2);
  } catch (error) {
    // Do nothing, we want to display the invalid JSON as a string, rather
    // than present an error.
  }
}

const updateURL = function() {
  const newSearch = Object.keys(parameters).map(function (key) {
    return `${encodeURIComponent(key)}=${encodeURIComponent(parameters[key])}`;
  }).join("&");

  history.replaceState(null, null, `?${newSearch}`);
}

// When the query and variables string is edited, update the URL bar so
// that it can be easily shared
const onEditQuery = function(newQuery) {
  parameters.query = newQuery;
  updateURL();
}

const onEditVariables = function(newVariables) {
  parameters.variables = newVariables;
  updateURL();
}

// Defines a GraphQL fetcher using the fetch API.
const graphQLFetcher = function(graphQLParams) {
  const graphQLEndpoint = window.Decidim.config.get("graphql_endpoint");
  return fetch(graphQLEndpoint, {
    method: "post",
    headers: JSON.parse(window.Decidim.config.get("request_headers")),
    body: JSON.stringify(graphQLParams),
    credentials: "include"
  }).then(function(response) {
    try {
      return response.json();
    } catch (error) {
      return {
        "status": response.status,
        "message": "The server responded with invalid JSON, this is probably a server-side error",
        "response": response.text()
      };
    }
  })
}

window.addEventListener("DOMContentLoaded", () => {
  // Render <GraphiQL /> into the body.
  ReactDOM.render(
    React.createElement(GraphiQL, {
      fetcher: graphQLFetcher,
      defaultQuery: window.Decidim.config.get("default_query"),
      query: parameters.query,
      variables: parameters.variables,
      onEditQuery: onEditQuery,
      onEditVariables: onEditVariables
    }),
    document.getElementById("graphiql-container")
  )
});
