import * as moment        from "moment";
import * as React         from "react";
import { ApolloProvider } from "react-apollo";

import apolloClient       from "./apollo_client";

const { I18n } = require("react-i18nify");

interface ApplicationProps {
  locale: string;
}

/**
 * Wrapper component for all React applications using Apollo
 * @class
 * @augments Component
 */
export default class Application extends React.Component<ApplicationProps, undefined> {
  constructor(props: ApplicationProps) {
    const { locale } = props;

    I18n.setLocale(locale);
    moment.locale(locale);

    super(props);
  }

  public render() {
    const { children } = this.props;

    return (
      <ApolloProvider client={apolloClient}>
        {children}
      </ApolloProvider>
    );
  }
}
