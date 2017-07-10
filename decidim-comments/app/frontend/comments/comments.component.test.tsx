import { mount } from "enzyme";
import * as React from "react";
import { MockedProvider } from "react-apollo/lib/test-utils";

import AddCommentForm from "./add_comment_form.component";
import CommentOrderSelector from "./comment_order_selector.component";
import CommentThread from "./comment_thread.component";
import Comments, { commentsQuery } from "./comments.component";

import generateCommentsData from "../support/generate_comments_data";
import generateUserData from "../support/generate_user_data";

import { addTypenameToDocument } from "apollo-client";
import { loadLocaleTranslations } from "../support/load_translations";

const { createWaitForElement } = require("enzyme-wait");

describe("<Comments />", () => {
  let mockedData: any = null;
  let commentable: any = {};
  let session: any = null;
  let wrapper: any = null;
  const commentableId = "1";
  const commentableType = "Decidim::DummyResource";
  const orderBy = "older";
  const reorderComments = jasmine.createSpy("reorderComments");

  beforeEach(() => {
    loadLocaleTranslations("en");
    const userData = generateUserData();
    const commentsData = generateCommentsData(15);

    commentable = {
      __typename: "DummyResourceType",
      id: commentableId,
      type: commentableType,
      acceptsNewComments: true,
      commentsHaveAlignment: true,
      commentsHaveVotes: true,
      comments: commentsData,
    };

    session = {
      __typename: "SessionType",
      user: userData,
    };

    mockedData = {
      session,
      commentable,
    };

    const query = addTypenameToDocument(commentsQuery);

    const variables = {
      commentableId,
      commentableType,
      orderBy,
    };

    const mocks = [
      {
        request: { query, variables },
        result: { data: mockedData },
      },
    ];

    wrapper = mount(
      <MockedProvider mocks={mocks}>
        <Comments commentableId={commentableId} commentableType={commentableType} orderBy={orderBy} />
      </MockedProvider>,
    );
  });

  it("renders loading-comments class and the respective loading text", () => {
    expect(wrapper.find(".loading-comments").exists()).toBeTruthy();
    expect(wrapper.find("h2").text()).toEqual("Loading comments ...");
  });

  it("renders a div of id comments", () => {
    expect(wrapper.find("#comments").exists()).toBeTruthy();
  });

  describe("renders a CommentThread component for each comment", () => {
    const waitForSample = createWaitForElement(".comments-list");

    it("and pass filter comment data as a prop to it", (done) => {
      waitForSample(wrapper).then(() => {
        expect(wrapper.find(CommentThread).length).toEqual(commentable.comments.length);
        wrapper.find(CommentThread).forEach((node: any, idx: number) => {
          expect(node.prop("comment")).toEqual(commentable.comments[idx]);
        });
        done();
      });
    });

    // it("and pass the session as a prop to it", () => {
    //   expect(wrapper.find(CommentThread).length).toEqual(commentable.comments.length);
    //   wrapper.find(CommentThread).forEach((node: any) => {
    //     expect(node.prop("session")).toEqual(session);
    //   });
    // });

    // it("and pass the commentable 'commentsHaveVotes' property as a prop to it", () => {
    //   expect(wrapper.find(CommentThread).length).toEqual(commentable.comments.length);
    //   wrapper.find(CommentThread).forEach((node: any) => {
    //     expect(node.prop("votable")).toBeTruthy();
    //   });
    // });
  });

  // it("renders comments count", () => {
  //   const wrapper = shallow(<Comments commentable={commentable} session={session} reorderComments={reorderComments} orderBy={orderBy} />);
  //   const rex = new RegExp(`${commentable.comments.length} comments`);
  //   expect(wrapper.find("h2.section-heading").text()).toMatch(rex);
  // });

  // it("renders a AddCommentForm component and pass the commentable 'commentsHaveAlignment' as a prop", () => {
  //   const wrapper = shallow(<Comments commentable={commentable} session={session} reorderComments={reorderComments} orderBy={orderBy} />);
  //   expect(wrapper.find(AddCommentForm).length).toEqual(1);
  //   expect(wrapper.find(AddCommentForm).prop("arguable")).toBeTruthy();
  // });

  // describe("when the commentable cannot accept new comments", () => {
  //   beforeEach(() => {
  //     commentable.acceptsNewComments = false;
  //   });

  //   it("doesn't render an AddCommentForm component", () => {
  //     const wrapper = shallow(<Comments commentable={commentable} session={session} reorderComments={reorderComments} orderBy={orderBy} />);
  //     expect(wrapper.find(AddCommentForm).exists()).toBeFalsy();
  //   });

  //   it("renders a callout message to inform the user that comments are blocked", () => {
  //     const wrapper = shallow(<Comments commentable={commentable} session={session} reorderComments={reorderComments} orderBy={orderBy} />);
  //     expect(wrapper.find(".callout.warning").text()).toContain("disabled");
  //   });
  // });

  // describe("renders a CommentOrderSelector component", () => {
  //   it("and pass the reorderComments as a prop to it", () => {
  //     const wrapper = shallow(<Comments commentable={commentable} session={session} reorderComments={reorderComments} orderBy={orderBy} />);
  //     expect(wrapper.find(CommentOrderSelector).prop("reorderComments")).toEqual(reorderComments);
  //   });

  //   it("and pass the orderBy as a prop to it", () => {
  //     const wrapper = shallow(<Comments commentable={commentable} session={session} reorderComments={reorderComments} orderBy={orderBy} />);
  //     expect(wrapper.find(CommentOrderSelector).prop("defaultOrderBy")).toEqual("older");
  //   });
  // });
});
