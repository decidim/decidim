import { shallow } from "enzyme";
import * as React from "react";

import Autocomplete from "./autocomplete.component";

describe("<Autocomplete />", () => {
  const name = "custom[name]";
  const selected = "";
  const options = Array();
  const placeholder = "Pick a value";
  const noResultsText = "No results found";
  const searchPromptText = "Type to search";
  const searchURL = "/some/url";

  it("renders a div of Select", () => {
    const wrapper = shallow(<Autocomplete name={name} selected={selected} options={options} noResultsText={noResultsText} placeholder={placeholder} searchPromptText={searchPromptText} searchURL={searchURL} />);
    expect(wrapper.find(".autocomplete-field").exists()).toBeTruthy();
  });
});
