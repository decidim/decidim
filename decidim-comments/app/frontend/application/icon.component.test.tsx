import { mount, shallow } from "enzyme";
import * as React from "react";

import { Icon } from "./icon.component";

describe("<Icon /", () => {
  beforeEach(() => {
    window.DecidimComments = {
      assets: {
        "icons.svg": "/assets/icons.svg"
      }
    };
  });

  it("should render a svg with class defined by prop className", () => {
    const wrapper = shallow(<Icon name="icon-thumb-down" />);
    expect(wrapper.find("svg.icon-thumb-down").exists()).toBeTruthy();
  });

  it("should render a svg icon using the 'icons.svg' url and name", () => {
    const wrapper = shallow(<Icon name="icon-thumb-up" />);
    expect(wrapper.find("svg use").prop("xlinkHref")).toBe(
      "/assets/icons.svg#icon-thumb-up"
    );
  });

  it("has a default prop iconExtraClassName with value 'icon--before'", () => {
    const wrapper = mount(<Icon name="icon-thumb-up" />);
    expect(wrapper.prop("iconExtraClassName")).toBe("icon--before");
  });

  it("renders the svg with an extra class defined by iconExtraClassName", () => {
    const wrapper = mount(
      <Icon name="icon-thumb-up" iconExtraClassName="icon--small" />
    );
    expect(wrapper.find(".icon--small").exists()).toBeTruthy();
  });
});
