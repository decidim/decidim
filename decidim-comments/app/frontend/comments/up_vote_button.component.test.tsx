import { shallow }          from "enzyme";
import * as React from "react";

import { UpVoteButton }     from "./up_vote_button.component";
import VoteButton           from "./vote_button.component";

import generateCommentsData from "../support/generate_comments_data";

import { UpVoteFragment } from "../support/schema";

describe("<UpVoteButton />", () => {
  let comment: UpVoteFragment;
  const upVote = jasmine.createSpy("upVote");

  beforeEach(() => {
    let commentsData = generateCommentsData(1);

    comment = commentsData[0];
  });

  it("should render a VoteButton component with the correct props", () => {
    const wrapper = shallow(<UpVoteButton comment={comment} upVote={upVote} />);
    expect(wrapper.find(VoteButton).prop("buttonClassName")).toEqual("comment__votes--up");
    expect(wrapper.find(VoteButton).prop("iconName")).toEqual("icon-chevron-top");
    expect(wrapper.find(VoteButton).prop("votes")).toEqual(comment.upVotes);
  });

  it("should pass disabled prop as true if comment upVoted is true", () => {
    comment.upVoted = true;
    const wrapper = shallow(<UpVoteButton comment={comment} upVote={upVote} />);
    expect(wrapper.find(VoteButton).prop("disabled")).toBeTruthy();
  });

  it("should pass disabled prop as true if comment downVoted is true", () => {
    comment.downVoted = true;
    const wrapper = shallow(<UpVoteButton comment={comment} upVote={upVote} />);
    expect(wrapper.find(VoteButton).prop("disabled")).toBeTruthy();
  });
});
