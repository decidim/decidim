import graphql, { filter } from 'graphql-anywhere';

/**
 * A simple resolver which returns object properties to easily
 * traverse a graphql response
 * @param {String} fieldName - An object property
 * @param {Object} root - An object
 * @returns {any} - An object's property value
 */
const resolver = (fieldName: string, root: any) => root[fieldName];

/**
 * A helper function to mock a graphql api request and return its
 * result. The result can be filtered by the same query so it just
 * returns a data subset.
 * @param {String} document - A graphql query document
 * @param {options} options - An object with optional options
 * @returns {Object} - The result of the query filtered or not
 */
const resolveGraphQLQuery = (document: any, options: any = {}) => {
  const { filterResult, rootValue, context, variables } = options;

  let result = graphql(
    resolver,
    document,
    rootValue,
    context,
    variables
  );

  if (filterResult) {
    return filter(document, result);
  }
  return result;
}

export default resolveGraphQLQuery;
