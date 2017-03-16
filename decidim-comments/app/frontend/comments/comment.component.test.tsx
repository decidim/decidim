import { mount, shallow }   from "enzyme";
import * as React from "react";

import { CommentFragment } from "../support/schema";
import AddCommentForm       from "./add_comment_form.component";
import Comment              from "./comment.component";
import DownVoteButton       from "./down_vote_button.component";
import UpVoteButton         from "./up_vote_button.component";

import generateCommentsData from "../support/generate_comments_data";
import generateUserData     from "../support/generate_user_data";

import { loadLocaleTranslations } from "../support/load_translations";

describe("<Comment />", () => {
  let comment: CommentFragment;
  let session: any = null;

  beforeEach(() => {
    loadLocaleTranslations("en");
    let commentsData = generateCommentsData(1);
    commentsData[0].comments = generateCommentsData(3);

    comment = commentsData[0];
    session = {
      user: generateUserData(),
    };
  });

  it("should render an article with class comment", () => {
    const wrapper = shallow(<Comment comment={comment} session={session} />);
    expect(wrapper.find("article.comment").exists()).toBeTruthy();
  });

  it("should render a time tag with comment's created at", () => {
    const wrapper = shallow(<Comment comment={comment} session={session} />);
    expect(wrapper.find("time").prop("dateTime")).toEqual(comment.createdAt);
  });

  it("should render author's name in a link with class author__name", () => {
    const wrapper = shallow(<Comment comment={comment} session={session} />);
    expect(wrapper.find("a.author__name").text()).toEqual(comment.author.name);
  });

  it("should render author's avatar as a image tag", () => {
    const wrapper = shallow(<Comment comment={comment} session={session} />);
    expect(wrapper.find("a.author__avatar img").prop("src")).toEqual(comment.author.avatarUrl);
  });

  it("should render comment's body on a div with class comment__content", () => {
    const wrapper = shallow(<Comment comment={comment} session={session} />);
    expect(wrapper.find("div.comment__content").text()).toEqual(comment.body);
  });

  it("should initialize with a state property showReplyForm as false", () => {
    const wrapper = shallow(<Comment comment={comment} session={session} />);
    expect(wrapper.state()).toHaveProperty("showReplyForm", false);
  });

  it("should render a AddCommentForm component with the correct props when clicking the reply button", () => {
    const wrapper = shallow(<Comment comment={comment} session={session} />);
    expect(wrapper.find(AddCommentForm).exists()).toBeFalsy();
    wrapper.find("button.comment__reply").simulate("click");
    expect(wrapper.find(AddCommentForm).prop("session")).toEqual(session);
    expect(wrapper.find(AddCommentForm).prop("commentable")).toEqual(comment);
    expect(wrapper.find(AddCommentForm).prop("showTitle")).toBeFalsy();
    expect(wrapper.find(AddCommentForm).prop("submitButtonClassName")).toEqual("button small hollow");
  });

  it("should not render the additional reply button if the parent comment has no comments and isRootcomment", () => {
    comment.hasComments = false;
    const wrapper = shallow(<Comment comment={comment} session={session} isRootComment={true} />);
    expect(wrapper.find("div.comment__additionalreply").exists()).toBeFalsy();
  });

  it("should not render the additional reply button if the parent comment has comments and not isRootcomment", () => {
    comment.hasComments = true;
    const wrapper = shallow(<Comment comment={comment} session={session} />);
    expect(wrapper.find("div.comment__additionalreply").exists()).toBeFalsy();
  });

  it("should render the additional reply button if the parent comment has comments and isRootcomment", () => {
    comment.hasComments = true;
    const wrapper = shallow(<Comment comment={comment} session={session} isRootComment={true} />);
    expect(wrapper.find("div.comment__additionalreply").exists()).toBeTruthy();
  });

  it("should render comment's comments as a separate Comment components", () => {
    const wrapper = shallow(<Comment comment={comment} session={session} votable={true} />);
    wrapper.find(Comment).forEach((node, idx) => {
      expect(node.prop("comment")).toEqual(comment.comments[idx]);
      expect(node.prop("session")).toEqual(session);
      expect(node.prop("articleClassName")).toEqual("comment comment--nested");
      expect(node.prop("votable")).toBeTruthy();
    });
  });

  it("should render comment's comments with articleClassName as 'comment comment--nested comment--nested--alt' when articleClassName is 'comment comment--nested'", () => {
    const wrapper = shallow(<Comment comment={comment} session={session} articleClassName="comment comment--nested" />);
    wrapper.find(Comment).forEach((node) => {
      expect(node.prop("articleClassName")).toEqual("comment comment--nested comment--nested--alt");
    });
  });

  it("should have a default prop articleClassName with value 'comment'", () => {
    const wrapper = mount(<Comment comment={comment} session={session} />);
    expect(wrapper.prop("articleClassName")).toEqual("comment");
  });

  it("should have a default prop isRootComment with value false", () => {
    const wrapper = mount(<Comment comment={comment} session={session} />);
    expect(wrapper.prop("isRootComment")).toBeFalsy();
  });

  describe("when the comment cannot accept new comments", () => {
    beforeEach(() => {
      comment.acceptsNewComments = false;
    });

    it("should not render the reply button", () => {
      const wrapper = shallow(<Comment comment={comment} session={session} />);
      expect(wrapper.find("button.comment__reply").exists()).toBeFalsy();
    });
  });

  describe("when user is not logged in", () => {
    beforeEach(() => {
      session = null;
    });

    it("should not render reply button", () => {
      const wrapper = shallow(<Comment comment={comment} session={session} />);
      expect(wrapper.find("button.comment__reply").exists()).toBeFalsy();
    });

    it("should not render the flag modal", () => {
      const wrapper = shallow(<Comment comment={comment} session={session} />);
      expect(wrapper.find(".flag-modal").exists()).toBeFalsy();
    });
  });

  it("should render a 'in favor' badge if comment's alignment is 1", () => {
    comment.alignment = 1;
    const wrapper = shallow(<Comment comment={comment} session={session} />);
    expect(wrapper.find("span.success.label").text()).toEqual("In favor");
  });

  it("should render a 'against' badge if comment's alignment is -1", () => {
    comment.alignment = -1;
    const wrapper = shallow(<Comment comment={comment} session={session} />);
    expect(wrapper.find("span.alert.label").text()).toEqual("Against");
  });

  it("should render the flag modal", () => {
    const wrapper = shallow(<Comment comment={comment} session={session} />);
    expect(wrapper.find(".flag-modal").exists()).toBeTruthy();
  });

  describe("when user has already reported the comment", () => {
    it("should not render the flag form", () => {
      comment.alreadyReported = true;
      const wrapper = shallow(<Comment comment={comment} session= {session} />);
      expect(wrapper.find(".flag-modal form").exists()).toBeFalsy();
    });
  });

  describe("when the comment is votable", () => {
    it("should render an UpVoteButton component", () => {
      const wrapper = shallow(<Comment comment={comment} session={session} votable={true} />);
      expect(wrapper.find(UpVoteButton).prop("comment")).toEqual(comment);
    });

    it("should render an DownVoteButton component", () => {
      const wrapper = shallow(<Comment comment={comment} session={session} votable={true} />);
      expect(wrapper.find(DownVoteButton).prop("comment")).toEqual(comment);
    });
  });
});
