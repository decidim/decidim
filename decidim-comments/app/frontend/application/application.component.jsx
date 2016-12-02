import { Component, PropTypes } from 'react';
import { ApolloProvider }       from 'react-apollo';
import { I18n }                 from 'react-i18nify';

import apolloClient             from './apollo_client';

export default class Application extends Component {
  constructor(props) {
    const { session } = props;

    if (session) {
      I18n.setLocale(session.locale);
    }
    
    super(props);
  }

  render() {
    const { children } = this.props;

    return (
      <ApolloProvider client={apolloClient}>
        {children}
      </ApolloProvider>
    );
  }
}

Application.propTypes = {
  children: PropTypes.element.isRequired,
  session: PropTypes.shape({
    locale: PropTypes.string.isRequired
  }).isRequired
};
