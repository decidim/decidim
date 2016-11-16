import { ApolloProvider } from 'react-apollo';

import apolloClient       from './apollo_client';

const ApolloApplicationComponent = ({ children }) => (
  <ApolloProvider client={apolloClient}>
    {children}
  </ApolloProvider>
);

export default ApolloApplicationComponent;
