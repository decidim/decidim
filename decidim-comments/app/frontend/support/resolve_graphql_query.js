/* eslint-disable no-ternary */
import graphql, { filter } from 'graphql-anywhere';
 
/**
 * A simple resolver which returns object properties to easily
 * traverse a graphql response
 * @param {String} - An object property
 * @param {Object} - An object
 * @returns {any} - An object's property value
 */
const resolver = (fieldName, root) => root[fieldName];

/** 
 * A helper function to mock a graphql api request and return its
 * result. The result can be filtered by the same query so it just
 * returns a data subset.
 */
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
