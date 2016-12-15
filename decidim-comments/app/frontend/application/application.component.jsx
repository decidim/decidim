import { Component, PropTypes } from 'react';
import { ApolloProvider }       from 'react-apollo';
import { I18n }                 from 'react-i18nify';
import moment                   from 'moment';

import apolloClient             from './apollo_client';

/**
 * Wrapper component for all React applications using Apollo
 * @class
 * @augments Component
 */
export default class Application extends Component {
  constructor(props) {
    const { locale } = props;

    I18n.setLocale(locale);
    moment.locale(locale);
    
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
  locale: PropTypes.string.isRequired
};
