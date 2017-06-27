import { mount, ReactWrapper } from "enzyme";
import * as React from "react";
import Icon from "../application/icon.component";
import VoteButton, { VoteButtonProps } from "./vote_button.component";

describe("<VoteButton />", () => {
  const voteAction: jasmine.Spy = jasmine.createSpy("voteAction");
  const preventDefault: jasmine.Spy = jasmine.createSpy("preventDefault");
  let wrapper: ReactWrapper<VoteButtonProps, null>;

  beforeEach(() => {
    voteAction.calls.reset();
    preventDefault.calls.reset();
    wrapper = mount(
      <VoteButton
        votes={10}
        buttonClassName="vote-button"
        iconName="vote-icon"
        voteAction={voteAction}
        userLoggedIn={true}
      />,
    );
  });

  it("should render the number of votes passed as a prop", () => {
    expect(wrapper.find("button").text()).toMatch(/10/);
  });

  it("should render a button with the given buttonClassName", () => {
    expect(wrapper.find("button.vote-button").exists()).toBeTruthy();
  });

  it("should render a Icon component with the correct name prop", () => {
    expect(wrapper.find(Icon).prop("name")).toEqual("vote-icon");
  });

  it("should call the voteAction prop on click", () => {
    wrapper.find("button").simulate("click");
    expect(voteAction).toHaveBeenCalled();
  });

  it("should disable the button based on the disabled prop", () => {
    wrapper = mount(
      <VoteButton
        votes={10}
        buttonClassName="vote-button"
        iconName="vote-icon"
        voteAction={voteAction}
        userLoggedIn={true}
        disabled={true}
      />,
    );
    expect(wrapper.find("button").props()).toHaveProperty("disabled");
  });

  it("should render a button with the given selectedClass", () => {
    wrapper = mount(
      <VoteButton
        votes={10}
        buttonClassName="vote-button"
        iconName="vote-icon"
        voteAction={voteAction}
        userLoggedIn={true}
        selectedClass="is-vote-selected"
      />,
    );
    expect(wrapper.find(".is-vote-selected").exists()).toBeTruthy();
  });

  describe("when userLoggedIn prop is false", () => {
    beforeEach(() => {
      wrapper = mount(<VoteButton votes={10} buttonClassName="vote-button" iconName="vote-icon" voteAction={voteAction} userLoggedIn={false} />);
    });

    it("should add data-open prop as 'loginModal' to the button", () => {
      expect(wrapper.find("button").prop("data-open")).toBe("loginModal");
    });

    it("should call the event preventDefault method", () => {
      wrapper.find("button").simulate("click", { preventDefault });
      expect(preventDefault).toHaveBeenCalled();
    });
  });
});
