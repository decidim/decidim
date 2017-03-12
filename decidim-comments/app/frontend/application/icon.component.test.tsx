import { mount, shallow } from "enzyme";

import * as React from "react";

import { Icon } from "./icon.component";

describe("<Icon /", () => {
  let userAgent: string;

  beforeEach(() => {
    window.DecidimComments = {
      assets: {
        "icons.svg": "/assets/icons.svg",
      },
    };

    userAgent = window.navigator.userAgent;
  });

  it("renders a simple span with the icon name", () => {
    const wrapper = shallow(<Icon name="icon-thumb-up" userAgent={userAgent} />);
    expect(wrapper.find("span").text()).toBe("icon-thumb-up");
  });

  it("has a default prop iconExtraClassName with value 'icon--before'", () => {
    const wrapper = mount(<Icon name="icon-thumb-up" userAgent={userAgent} />);
    expect(wrapper.prop("iconExtraClassName")).toBe("icon--before");
  });

  it("renders the svg with an extra class defined by iconExtraClassName", () => {
    const wrapper = mount(<Icon name="icon-thumb-up" userAgent={userAgent} iconExtraClassName="icon--small" />);
    expect(wrapper.find(".icon--small").exists()).toBeTruthy();
  });

  describe("if user agent is not PhantomJS neither Node", () => {
    beforeEach(() => {
      userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.98 Safari/537.36";
    });

    it("should render a svg with class defined by prop className", () => {
      const wrapper = shallow(<Icon name="icon-thumb-down" userAgent={userAgent} />);
      expect(wrapper.find("svg.icon-thumb-down").exists()).toBeTruthy();
    });

    it("should render a svg icon using the 'icons.svg' url and name", () => {
      const wrapper = shallow(<Icon name="icon-thumb-up" userAgent={userAgent} />);
      expect(wrapper.find("svg use").prop("xlinkHref")).toBe("/assets/icons.svg#icon-thumb-up");
    });
  });
});
