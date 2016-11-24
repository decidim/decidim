import { PropTypes }                 from 'react';
import { ApolloProvider }            from 'react-apollo';

import apolloClient                  from './apollo_client';

const ApolloApplication = ({ children }) => (
  <ApolloProvider client={apolloClient}>
    {children}
  </ApolloProvider>
);

ApolloApplication.propTypes = {
  children: PropTypes.element.isRequired
};

export default ApolloApplication;
