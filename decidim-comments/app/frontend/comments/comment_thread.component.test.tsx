import { shallow } from "enzyme";
import * as React from "react";

import { CommentFragment } from "../support/schema";
import Comment from "./comment.component";
import CommentThread from "./comment_thread.component";

import generateCommentsData from "../support/generate_comments_data";
import generateCUserData from "../support/generate_user_data";
import { loadLocaleTranslations } from "../support/load_translations";

describe("<CommentThread />", () => {
  let comment: CommentFragment;
  let session: any = null;

  beforeEach(() => {
    loadLocaleTranslations("en");
    const commentsData = generateCommentsData(1);

    session = {
      user: generateCUserData(),
    };
    comment = commentsData[0];
  });

  describe("when comment doesn't have comments", () => {
    it("should not render a title with author name", () => {
      const wrapper = shallow(<CommentThread comment={comment} session={session} />);
      expect(wrapper.find("h6.comment-thread__title").exists()).toBeFalsy();
    });
  });

  describe("when comment does has comments", () => {
    beforeEach(() => {
      comment.hasComments = true;
    });

    it("should render a h6 comment-thread__title with author name", () => {
      const wrapper = shallow(<CommentThread comment={comment} session={session} />);
      expect(wrapper.find("h6.comment-thread__title").text()).toContain(`Conversation with ${comment.author.name}`);
    });
  });

  describe("should render a Comment", () => {
    it("and pass the session as a prop to it", () => {
      const wrapper = shallow(<CommentThread comment={comment} session={session} />);
      expect(wrapper.find(Comment).first().props()).toHaveProperty("session", session);
    });

    it("and pass comment data as a prop to it", () => {
      const wrapper = shallow(<CommentThread comment={comment} session={session} />);
      expect(wrapper.find(Comment).first().props()).toHaveProperty("comment", comment);
    });

    it("and pass the votable as a prop to it", () => {
      const wrapper = shallow(<CommentThread comment={comment} session={session} votable={true} />);
      expect(wrapper.find(Comment).first().props()).toHaveProperty("votable", true);
    });

    it("and pass the isRootComment equal true", () => {
      const wrapper = shallow(<CommentThread comment={comment} session={session} votable={true} />);
      expect(wrapper.find(Comment).first().props()).toHaveProperty("isRootComment", true);
    });
  });
});
