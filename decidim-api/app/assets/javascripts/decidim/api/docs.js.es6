// = require jquery
// = require decidim/api/react
// = require decidim/api/react-dom
// = require decidim/api/graphql-docs

const fetcherFactory = (path) => {
  return (query) => {
    return jQuery.ajax({
      url: path,
      data: JSON.stringify({ query }),
      method: 'POST',
      contentType: 'application/json',
      dataType: 'json'
    });
  };
}

window.renderDocumentation = (path) => {
  ReactDOM.render(
    <GraphQLDocs.GraphQLDocs fetcher={fetcherFactory(path)} />,
    document.getElementById('documentation'),
  );
};
