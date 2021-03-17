import axios from "axios";
import * as React from "react";
import { Async as AsyncSelect } from "react-select";
import "react-select/scss/default.scss";
export class Autocomplete extends React.Component {
    constructor(props) {
        super(props);
        this.minCharactersToSearch = 3;
        this.handleChange = (selectedOption) => {
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
                    .catch((error) => {
                    if (axios.isCancel(error)) {
                        // console.log("Request canceled", error.message);
                    }
                    else {
                        //
                    }
                });
            }
        };
        this.filterOptions = (options, filter, excludeOptions) => {
            // Do no filtering, just return all options because
            // we return a filtered set from server
            return options;
        };
        this.onInputChange = (query) => {
            if (query.length < this.minCharactersToSearch) {
                this.setState({ noResultsText: this.props.searchPromptText });
            }
            else {
                this.setState({ noResultsText: this.props.noResultsText });
            }
        };
        this.loadOptions = (query, callback) => {
            query = query.toLowerCase();
            if (this.cancelTokenSource) {
                this.cancelTokenSource.cancel();
            }
            if (query.length < this.minCharactersToSearch) {
                callback(null, { options: [], complete: false });
            }
            else {
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
                    callback(null, { options: response.data, complete: true });
                })
                    .catch((error) => {
                    if (axios.isCancel(error)) {
                        // console.log("Request canceled", error.message);
                    }
                    else {
                        callback(error, { options: [], complete: false });
                    }
                });
            }
        };
        this.state = {
            options: props.options,
            selectedOption: props.selected,
            searchPromptText: props.searchPromptText,
            noResultsText: props.noResultsText
        };
    }
    render() {
        const { autoload, name, placeholder } = this.props;
        const { selectedOption, options, searchPromptText, noResultsText } = this.state;
        return (React.createElement("div", { className: "autocomplete-field" },
            React.createElement(AsyncSelect, { cache: false, name: name, value: selectedOption, options: options, placeholder: placeholder, searchPromptText: searchPromptText, noResultsText: noResultsText, onChange: this.handleChange, onInputChange: this.onInputChange, loadOptions: this.loadOptions, filterOptions: this.filterOptions, autoload: autoload, removeSelected: true, escapeClearsValue: false, onCloseResetsInput: false })));
    }
}
Autocomplete.defaultProps = {
    autoload: false
};
export default Autocomplete;
