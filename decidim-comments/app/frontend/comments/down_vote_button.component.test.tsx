import { shallow } from "enzyme";
import * as React from "react";

import { DownVoteButton } from "./down_vote_button.component";
import VoteButton from "./vote_button.component";

import generateCommentsData from "../support/generate_comments_data";
import generateUserData from "../support/generate_user_data";

import { DownVoteButtonFragment } from "../support/schema";

describe("<DownVoteButton />", () => {
  let comment: DownVoteButtonFragment;
  let session: any = null;
  const downVote = jasmine.createSpy("downVote");

  beforeEach(() => {
    const commentsData = generateCommentsData(1);
    session = {
      user: generateUserData(),
    };
    comment = commentsData[0];
  });

  it("should render a VoteButton component with the correct props", () => {
    const wrapper = shallow(<DownVoteButton session={session} comment={comment} downVote={downVote} />);
    expect(wrapper.find(VoteButton).prop("buttonClassName")).toEqual("comment__votes--down");
    expect(wrapper.find(VoteButton).prop("iconName")).toEqual("icon-chevron-bottom");
    expect(wrapper.find(VoteButton).prop("votes")).toEqual(comment.downVotes);
  });

  it("should pass disabled prop as true if comment downVoted is true", () => {
    comment.downVoted = true;
    const wrapper = shallow(<DownVoteButton session={session} comment={comment} downVote={downVote} />);
    expect(wrapper.find(VoteButton).prop("disabled")).toBeTruthy();
  });

  it("should pass disabled prop as true if comment downVoted is true", () => {
    comment.downVoted = true;
    const wrapper = shallow(<DownVoteButton session={session} comment={comment} downVote={downVote} />);
    expect(wrapper.find(VoteButton).prop("disabled")).toBeTruthy();
  });

  describe("when session is not present", () => {
    beforeEach(() => {
      session = null;
    });

    it("should pass userLoggedIn as false", () => {
      const wrapper = shallow(<DownVoteButton session={session} comment={comment} downVote={downVote} />);
      expect(wrapper.find(VoteButton).prop("userLoggedIn")).toBeFalsy();
    });
  });
});
