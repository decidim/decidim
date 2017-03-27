import { shallow } from "enzyme";
import * as React from "react";
import Icon        from "../application/icon.component";
import VoteButton  from "./vote_button.component";

describe("<VoteButton />", () => {
  const voteAction: jasmine.Spy = jasmine.createSpy("voteAction");

  it("should render the number of votes passed as a prop", () => {
    const wrapper = shallow(<VoteButton votes={10} buttonClassName="vote-button" iconName="vote-icon" voteAction={voteAction} />);
    expect(wrapper.find("button").text()).toMatch(/10/);
  });

  it("should render a button with the given buttonClassName", () => {
    const wrapper = shallow(<VoteButton votes={10} buttonClassName="vote-button" iconName="vote-icon" voteAction={voteAction} />);
    expect(wrapper.find("button.vote-button").exists()).toBeTruthy();
  });

  it("should render a Icon component with the correct name prop", () => {
    const wrapper = shallow(<VoteButton votes={10} buttonClassName="vote-button" iconName="vote-icon" voteAction={voteAction} />);
    expect(wrapper.find(Icon).prop("name")).toEqual("vote-icon");
  });

  it("should call the voteAction prop on click", () => {
    const wrapper = shallow(<VoteButton votes={10} buttonClassName="vote-button" iconName="vote-icon" voteAction={voteAction} />);
    wrapper.find("button").simulate("click");
    expect(voteAction).toHaveBeenCalled();
  });

  it("should disable the button based on the disabled prop", () => {
    const wrapper = shallow(<VoteButton votes={10} buttonClassName="vote-button" iconName="vote-icon" voteAction={voteAction} disabled={true} />);
    expect(wrapper.find("button").props()).toHaveProperty("disabled");
  });

  it("should render a button with the given selectedClass", () => {
    const wrapper = shallow(<VoteButton votes={10} buttonClassName="vote-button" iconName="vote-icon" voteAction={voteAction} disabled={true} selectedClass="is-vote-selected" />);
    expect(wrapper.find(".is-vote-selected").exists()).toBeTruthy();
  });
});
