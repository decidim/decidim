import graphql, { filter } from 'graphql-anywhere';

const resolver = (fieldName, root) => root[fieldName];

const resolveGraphQLQuery = (query, data) => {
  let result = graphql(
    resolver,
    query,
    data
  );

  return filter(query, result);
}

export default resolveGraphQLQuery;
