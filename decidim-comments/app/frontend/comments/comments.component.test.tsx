import { shallow } from "enzyme";
import * as React from "react";

import AddCommentForm from "./add_comment_form.component";
import CommentOrderSelector from "./comment_order_selector.component";
import CommentThread from "./comment_thread.component";
import { Comments, commentsQuery } from "./comments.component";

import generateCommentsData from "../support/generate_comments_data";
import generateUserData from "../support/generate_user_data";
import resolveGraphQLQuery from "../support/resolve_graphql_query";

import { loadLocaleTranslations } from "../support/load_translations";

describe("<Comments commentsMaxLength={commentsMaxLength} />", () => {
  let commentable: any = {};
  let session: any = null;
  const commentsMaxLength: number = 1000;
  const commentableId = "1";
  const commentableType = "Decidim::DummyResources::DummyResource";
  const orderBy = "older";
  const reorderComments = jasmine.createSpy("reorderComments");

  beforeEach(() => {
    loadLocaleTranslations("en");
    const userData = generateUserData();
    const commentsData = generateCommentsData(15);

    const result = resolveGraphQLQuery(commentsQuery, {
      filterResult: false,
      rootValue: {
        session: {
          user: userData
        },
        commentable: {
          acceptsNewComments: true,
          userAllowedToComment: true,
          commentsHaveAlignment: true,
          commentsHaveVotes: true,
          totalCommentsCount: 15,
          comments: commentsData
        }
      },
      variables: {
        orderBy,
        commentableId,
        commentableType
      }
    });

    session = result.session;
    commentable = result.commentable;
  });

  it("renders loading-comments class and the respective loading text", () => {
    const wrapper = shallow(<Comments commentsMaxLength={commentsMaxLength} commentable={commentable} session={session} reorderComments={reorderComments} orderBy={orderBy} loading={true} />);
    expect(wrapper.find(".loading-comments").exists()).toBeTruthy();
    expect(wrapper.find("h2").text()).toEqual("Loading comments ...");
  });

  it("renders a div of id comments", () => {
    const wrapper = shallow(<Comments commentsMaxLength={commentsMaxLength} commentable={commentable} session={session} reorderComments={reorderComments} orderBy={orderBy} />);
    expect(wrapper.find("#comments").exists()).toBeTruthy();
  });

  describe("renders a CommentThread component for each comment", () => {
    it("and pass filter comment data as a prop to it", () => {
      const wrapper = shallow(<Comments commentsMaxLength={commentsMaxLength} commentable={commentable} session={session} reorderComments={reorderComments} orderBy={orderBy} />);
      expect(wrapper.find(CommentThread).length).toEqual(commentable.comments.length);
      wrapper.find(CommentThread).forEach((node, idx) => {
        expect(node.prop("comment")).toEqual(commentable.comments[idx]);
      });
    });

    it("and pass the session as a prop to it", () => {
      const wrapper = shallow(<Comments commentsMaxLength={commentsMaxLength} commentable={commentable} session={session} reorderComments={reorderComments} orderBy={orderBy} />);
      expect(wrapper.find(CommentThread).length).toEqual(commentable.comments.length);
      wrapper.find(CommentThread).forEach((node) => {
        expect(node.prop("session")).toEqual(session);
      });
    });

    it("and pass the commentable 'commentsHaveVotes' property as a prop to it", () => {
      const wrapper = shallow(<Comments commentsMaxLength={commentsMaxLength} commentable={commentable} session={session} reorderComments={reorderComments} orderBy={orderBy} />);
      expect(wrapper.find(CommentThread).length).toEqual(commentable.comments.length);
      wrapper.find(CommentThread).forEach((node) => {
        expect(node.prop("votable")).toBeTruthy();
      });
    });
  });

  it("renders comments count", () => {
    const wrapper = shallow(<Comments commentsMaxLength={commentsMaxLength} commentable={commentable} session={session} reorderComments={reorderComments} orderBy={orderBy} />);
    const rex = new RegExp(`${commentable.comments.length} comments`);
    expect(wrapper.find("h2.section-heading").text()).toMatch(rex);
  });

  it("renders a AddCommentForm component and pass the commentable 'commentsHaveAlignment' as a prop", () => {
    const wrapper = shallow(<Comments commentsMaxLength={commentsMaxLength} commentable={commentable} session={session} reorderComments={reorderComments} orderBy={orderBy} />);
    expect(wrapper.find(AddCommentForm).length).toEqual(1);
    expect(wrapper.find(AddCommentForm).prop("arguable")).toBeTruthy();
  });

  describe("when the commentable cannot accept new comments", () => {
    beforeEach(() => {
      commentable.acceptsNewComments = false;
      commentable.userAllowedToComment = false;
    });

    it("doesn't render an AddCommentForm component", () => {
      const wrapper = shallow(<Comments commentsMaxLength={commentsMaxLength} commentable={commentable} session={session} reorderComments={reorderComments} orderBy={orderBy} />);
      expect(wrapper.find(AddCommentForm).exists()).toBeFalsy();
    });

    it("renders a callout message to inform the user that comments are blocked", () => {
      const wrapper = shallow(<Comments commentsMaxLength={commentsMaxLength} commentable={commentable} session={session} reorderComments={reorderComments} orderBy={orderBy} />);
      expect(wrapper.find(".callout.warning").text()).toContain("disabled");
    });
  });

  describe("when the commentable can accept new comments but user is not allowed to comment", () => {
    beforeEach(() => {
      commentable.userAllowedToComment = false;
    });

    it("doesn't render an AddCommentForm component", () => {
      const wrapper = shallow(<Comments commentsMaxLength={commentsMaxLength} commentable={commentable} session={session} reorderComments={reorderComments} orderBy={orderBy} />);
      expect(wrapper.find(AddCommentForm).exists()).toBeFalsy();
    });

    it("renders a callout message to inform the user that comments are blocked", () => {
      const wrapper = shallow(<Comments commentsMaxLength={commentsMaxLength} commentable={commentable} session={session} reorderComments={reorderComments} orderBy={orderBy} />);
      expect(wrapper.find(".callout.warning").text()).toContain("not able");
    });
  });

  describe("renders a CommentOrderSelector component", () => {
    it("and pass the reorderComments as a prop to it", () => {
      const wrapper = shallow(<Comments commentsMaxLength={commentsMaxLength} commentable={commentable} session={session} reorderComments={reorderComments} orderBy={orderBy} />);
      expect(wrapper.find(CommentOrderSelector).prop("reorderComments")).toEqual(reorderComments);
    });

    it("and pass the orderBy as a prop to it", () => {
      const wrapper = shallow(<Comments commentsMaxLength={commentsMaxLength} commentable={commentable} session={session} reorderComments={reorderComments} orderBy={orderBy} />);
      expect(wrapper.find(CommentOrderSelector).prop("defaultOrderBy")).toEqual("older");
    });
  });
});
