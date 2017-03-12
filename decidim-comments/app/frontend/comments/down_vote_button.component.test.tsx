import { shallow }          from "enzyme";
import gql                  from "graphql-tag";
import * as React from "react";

import { DownVoteButton }   from "./down_vote_button.component";

import VoteButton           from "./vote_button.component";

import generateCommentsData from "../support/generate_comments_data";

const downVoteFragment = require("./down_vote.fragment.graphql");

import { DownVoteFragment } from "../support/schema";

describe("<DownVoteButton />", () => {
  let comment: DownVoteFragment;
  const downVote = jasmine.createSpy("downVote");

  beforeEach(() => {
    let commentsData = generateCommentsData(1);

    const fragment = gql`
      ${downVoteFragment}
    `;

    comment = commentsData[0];
  });

  it("should render a VoteButton component with the correct props", () => {
    const wrapper = shallow(<DownVoteButton comment={comment} downVote={downVote} />);
    expect(wrapper.find(VoteButton).prop("buttonClassName")).toEqual("comment__votes--down");
    expect(wrapper.find(VoteButton).prop("iconName")).toEqual("icon-chevron-bottom");
    expect(wrapper.find(VoteButton).prop("votes")).toEqual(comment.downVotes);
  });

  it("should pass disabled prop as true if comment downVoted is true", () => {
    comment.downVoted = true;
    const wrapper = shallow(<DownVoteButton comment={comment} downVote={downVote} />);
    expect(wrapper.find(VoteButton).prop("disabled")).toBeTruthy();
  });

  it("should pass disabled prop as true if comment downVoted is true", () => {
    comment.downVoted = true;
    const wrapper = shallow(<DownVoteButton comment={comment} downVote={downVote} />);
    expect(wrapper.find(VoteButton).prop("disabled")).toBeTruthy();
  });
});
