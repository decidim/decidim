/* eslint-disable react/jsx-no-undef */

import jQuery from 'jquery'
import React from 'react'
import ReactDOM from 'react-dom'
import GraphQLDocs from 'graphql-docs'

const fetcherFactory = (path) => {
  return (query) => {
    return jQuery.ajax({
      url: path,
      data: JSON.stringify({ query }),
      method: "POST",
      contentType: "application/json",
      dataType: "json"
    });
  };
}

window.renderDocumentation = (path) => {
  ReactDOM.render(
    <GraphQLDocs.GraphQLDocs fetcher={fetcherFactory(path)} />,
    document.getElementById("documentation"),
  );
};
