import { shallow } from "enzyme";
import * as React from "react";
import CommentOrderSelector from "./comment_order_selector.component";

describe("<CommentOrderSelector />", () => {
  const orderBy = "older";
  const reorderComments = jasmine.createSpy("reorderComments");

  it("renders a div with classes order-by__dropdown order-by__dropdown--right", () => {
    const wrapper = shallow(<CommentOrderSelector reorderComments={reorderComments} defaultOrderBy={orderBy} />);
    expect(wrapper.find("div.order-by__dropdown.order-by__dropdown--right")).toBeDefined();
  });

  it("should set state order to best_rated if user clicks on the first element", () => {
      const preventDefault = jasmine.createSpy("preventDefault");
      const wrapper = shallow(<CommentOrderSelector reorderComments={reorderComments} defaultOrderBy={orderBy} />);
      wrapper.find("a.test").simulate("click", {preventDefault});
      expect(reorderComments).toBeCalledWith("best_rated");
    });
});
