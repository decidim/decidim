import axios, { CancelTokenSource } from "axios";
import * as React from "react";

import {Async as AsyncSelect, ReactAsyncSelectProps} from "react-select";
import "react-select/scss/default.scss";

declare module "react-select" {
  interface ReactAsyncSelectProps<TValue = OptionValues> {
    searchPromptText?: any;
  }
}

export interface AutocompleteProps {
  /**
   * Autoload from search url on initialize
   */
  autoload?: boolean;
  /**
   * The name of the input to be submitted with the form
   */
  name: string;
  /**
   * The value of the actually selected option
   */
  selected: any;
  /**
   * An array objects with the preloded options (needs to include the selected option)
   */
  options: any[];
  /**
   * placeholder displayed when there are no matching search results or a falsy value to hide it
   */
  noResultsText: string;
  /**
   * Field placeholder, displayed when there's no value
   */
  placeholder: string;
  /**
   * Text to prompt for search input
   */
  searchPromptText: string;
  /**
   * The URL where fetch content
   */
  searchURL: string;
  /**
   * The URL to call when selected option changes
   */
  changeURL: string;
}

interface AutocompleteState {
  /**
   * The value of the actually selected option
   */
  selectedOption: any;
  /**
   * An array objects with the preloded options (needs to include the selected option)
   */
  options: any[];
  /**
   * Text to prompt for search input
   */
  searchPromptText: string;
  /**
   * Placeholder displayed when there are no matching search results or a falsy value to hide it
   */
  noResultsText: string;
}

export class Autocomplete extends React.Component<AutocompleteProps, AutocompleteState> {
  public static defaultProps: any = {
    autoload: false
  };

  private cancelTokenSource: CancelTokenSource;
  private minCharactersToSearch: number = 3;

  constructor(props: AutocompleteProps) {
    super(props);

    this.state = {
      options: props.options,
      selectedOption: props.selected,
      searchPromptText: props.searchPromptText,
      noResultsText: props.noResultsText
    };
  }

  public render(): JSX.Element {
    const { autoload, name, placeholder } = this.props;
    const { selectedOption, options, searchPromptText, noResultsText } = this.state;

    return (
      <div className="autocomplete-field">
        <AsyncSelect
          cache={false}
          name={name}
          value={selectedOption}
          options={options}
          placeholder={placeholder}
          searchPromptText={searchPromptText}
          noResultsText={noResultsText}
          onChange={this.handleChange}
          onInputChange={this.onInputChange}
          loadOptions={this.loadOptions}
          filterOptions={this.filterOptions}
          autoload={autoload}
          removeSelected={true}
          escapeClearsValue={false}
          onCloseResetsInput={false}
        />
      </div>
    );
  }

  private handleChange = (selectedOption: any) => {
    this.setState({ selectedOption });

    if (this.props.changeURL) {
      axios.get(this.props.changeURL, {
        headers: {
          Accept: "text/javascript"
        },
        withCredentials: true,
        params: {
          id: selectedOption.value
        }
      })
      .then((response) => {
        const script = document.createElement("script");
        script.type = "text/javascript";
        script.innerHTML = response.data;
        document.getElementsByTagName("head")[0].appendChild(script);
      })
      .catch((error: any) => {
        if (axios.isCancel(error)) {
          // console.log("Request canceled", error.message);
        } else {
          //
        }
      });
    }
  }

  private filterOptions = (options: any, filter: any, excludeOptions: any) => {
    // Do no filtering, just return all options because
    // we return a filtered set from server
    return options;
  }

  private onInputChange = (query: string) => {
    if (query.length < this.minCharactersToSearch) {
      this.setState({ noResultsText: this.props.searchPromptText });
    } else {
      this.setState({ noResultsText: this.props.noResultsText });
    }
  }

  private loadOptions = (query: string, callback: any) => {
    query = query.toLowerCase();

    if (this.cancelTokenSource) {
      this.cancelTokenSource.cancel();
    }

    if (query.length < this.minCharactersToSearch) {
      callback (null, { options: [], complete: false });
    } else {
      this.cancelTokenSource = axios.CancelToken.source();

      axios.get(this.props.searchURL, {
        cancelToken: this.cancelTokenSource.token,
        headers: {
          Accept: "application/json"
        },
        withCredentials: true,
        params: {
          term: query
        }
      })
      .then((response) => {
        // CAREFUL! Only set complete to true when there are no more options,
        // or more specific queries will not be sent to the server.
        callback (null, { options: response.data, complete: true });
      })
      .catch((error: any) => {
        if (axios.isCancel(error)) {
          // console.log("Request canceled", error.message);
        } else {
          callback (error, { options: [], complete: false });
        }
      });
    }
  }
}

export default Autocomplete;
