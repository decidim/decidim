import { shallow } from "enzyme";
import * as React from "react";
import Icon from "../application/icon.component";
import VoteButton from "./vote_button.component";

describe("<VoteButton />", () => {
  const voteAction: jasmine.Spy = jasmine.createSpy("voteAction");
  const preventDefault: jasmine.Spy = jasmine.createSpy("preventDefault");

  beforeEach(() => {
    voteAction.calls.reset();
    preventDefault.calls.reset();
  });

  it("should render the number of votes passed as a prop", () => {
    const wrapper = shallow(<VoteButton votes={10} buttonClassName="vote-button" iconName="vote-icon" voteAction={voteAction} userLoggedIn={true} />);
    expect(wrapper.find("button").text()).toMatch(/10/);
  });

  it("should render a button with the given buttonClassName", () => {
    const wrapper = shallow(<VoteButton votes={10} buttonClassName="vote-button" iconName="vote-icon" voteAction={voteAction} userLoggedIn={true} />);
    expect(wrapper.find("button.vote-button").exists()).toBeTruthy();
  });

  it("should render a Icon component with the correct name prop", () => {
    const wrapper = shallow(<VoteButton votes={10} buttonClassName="vote-button" iconName="vote-icon" voteAction={voteAction} userLoggedIn={true} />);
    expect(wrapper.find(Icon).prop("name")).toEqual("vote-icon");
  });

  it("should call the voteAction prop on click", () => {
    const wrapper = shallow(<VoteButton votes={10} buttonClassName="vote-button" iconName="vote-icon" voteAction={voteAction} userLoggedIn={true} />);
    wrapper.find("button").simulate("click");
    expect(voteAction).toHaveBeenCalled();
  });

  it("should disable the button based on the disabled prop", () => {
    const wrapper = shallow(<VoteButton votes={10} buttonClassName="vote-button" iconName="vote-icon" voteAction={voteAction} disabled={true} userLoggedIn={true} />);
    expect(wrapper.find("button").props()).toHaveProperty("disabled");
  });

  it("should render a button with the given selectedClass", () => {
    const wrapper = shallow(<VoteButton votes={10} buttonClassName="vote-button" iconName="vote-icon" voteAction={voteAction} disabled={true} selectedClass="is-vote-selected" userLoggedIn={true} />);
    expect(wrapper.find(".is-vote-selected").exists()).toBeTruthy();
  });

  describe("when userLoggedIn prop is false", () => {
    it("should add data-open prop as 'loginModal' to the button", () => {
      const wrapper = shallow(<VoteButton votes={10} buttonClassName="vote-button" iconName="vote-icon" voteAction={voteAction} userLoggedIn={false} />);
      expect(wrapper.find("button").prop("data-open")).toBe("loginModal");
    });

    it("should call the event preventDefault method", () => {
      const wrapper = shallow(<VoteButton votes={10} buttonClassName="vote-button" iconName="vote-icon" voteAction={voteAction} userLoggedIn={false} />);
      wrapper.find("button").simulate("click", { preventDefault });
      expect(preventDefault).toHaveBeenCalled();
    });
  });
});
