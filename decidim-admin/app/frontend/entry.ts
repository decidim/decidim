import * as React from "react";
import * as ReactDOM from "react-dom";

import Autocomplete, { AutocompleteProps } from "./components/autocomplete.component";

window.DecidimAdmin = window.DecidimAdmin || {};

window.DecidimAdmin.renderAutocompleteSelects = (nodeSelector: string) => {
  window.$(nodeSelector).each((index: number, node: HTMLElement) => {
    const props: AutocompleteProps = { ...window.$(node).data("autocomplete") };

    ReactDOM.render(
      React.createElement(Autocomplete, props),
      node
    );
  });
};
