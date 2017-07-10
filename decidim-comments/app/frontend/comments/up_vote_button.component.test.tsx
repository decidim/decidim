import { mount } from "enzyme";
import * as React from "react";
import { MockedProvider } from "react-apollo/lib/test-utils";

import UpVoteButton, { UpVoteButtonProps } from "./up_vote_button.component";
import VoteButton from "./vote_button.component";

import generateCommentsData from "../support/generate_comments_data";
import generateUserData from "../support/generate_user_data";

import { UpVoteButtonFragment } from "../support/schema";

const mountTestComponent = ({ session, comment }: UpVoteButtonProps) => (
  mount(
    <MockedProvider>
      <UpVoteButton session={session} comment={comment} />
    </MockedProvider>,
  )
);

describe("<DownVoteButton />", () => {
  let comment: UpVoteButtonFragment;
  let session: any = null;
  let wrapper: any = null;
  const upVote = jasmine.createSpy("upVote");

  beforeEach(() => {
    const commentsData = generateCommentsData(1);
    session = {
      user: generateUserData(),
    };
    comment = commentsData[0];
    wrapper = mountTestComponent({ session, comment });
  });

  it("should render a VoteButton component with the correct props", () => {
    expect(wrapper.find(VoteButton).prop("buttonClassName")).toEqual("comment__votes--up");
    expect(wrapper.find(VoteButton).prop("iconName")).toEqual("icon-chevron-top");
    expect(wrapper.find(VoteButton).prop("votes")).toEqual(comment.upVotes);
  });

  describe("when the comment is upVoted", () => {
    beforeEach(() => {
      comment.upVoted = true;
      wrapper = mountTestComponent({ session, comment });
    });

    it("should pass disabled prop as true if comment upVoted is true", () => {
      expect(wrapper.find(VoteButton).prop("disabled")).toBeTruthy();
    });
  });

  describe("when the comment is downVoted", () => {
    beforeEach(() => {
      comment.downVoted = true;
      wrapper = mountTestComponent({ session, comment });
    });

    it("should pass disabled prop as true if comment downVoted is true", () => {
      expect(wrapper.find(VoteButton).prop("disabled")).toBeTruthy();
    });
  });

  describe("when session is not present", () => {
    beforeEach(() => {
      session = null;
      wrapper = mountTestComponent({ session, comment });
    });

    it("should pass userLoggedIn as false", () => {
      expect(wrapper.find(VoteButton).prop("userLoggedIn")).toBeFalsy();
    });
  });
});
