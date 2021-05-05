/* eslint-disable react/jsx-no-undef */

import jQuery from "jquery"
import { render } from "react-dom"
import { GraphQLDocs } from "graphql-docs"
import "stylesheets/decidim/api/docs.scss"

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
  render(
    <GraphQLDocs fetcher={fetcherFactory(path)} />,
    document.getElementById("documentation"),
  );
};

