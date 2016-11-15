//= require jquery
//= require decidim/api/react
//= require decidim/api/react-dom
//= require decidim/api/graphql-docs

function fetcherFactory(path) {
  return function fetcher(query) {
    return jQuery.ajax({
      url: path,
      data: JSON.stringify({ query }),
      method: 'POST',
      contentType: 'application/json',
      dataType: 'json'
    });
  };
}

window.renderDocumentation = function renderDocumentation(path) {
  ReactDOM.render(
    <GraphQLDocs.GraphQLDocs fetcher={fetcherFactory(path)} />,
    document.getElementById('documentation'),
  );
};
