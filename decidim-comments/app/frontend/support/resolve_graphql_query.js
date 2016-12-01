/* eslint-disable no-ternary */
import graphql, { filter } from 'graphql-anywhere';

const resolver = (fieldName, root) => root[fieldName];

const resolveGraphQLQuery = (document, options = {}) => {
  const { filterResult, rootValue, context, variables } = options;

  let result = graphql(
    resolver,
    document,
    rootValue,
    context,
    variables
  );

  return filterResult ? filter(document, result) : result;
}

export default resolveGraphQLQuery;
