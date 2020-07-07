import { mount, ReactWrapper, shallow } from "enzyme";
import * as $ from "jquery";
import * as React from "react";

import { AddCommentForm } from "./add_comment_form.component";

import generateUserData from "../support/generate_user_data";
import generateUserGroupData from "../support/generate_user_group_data";
import { loadLocaleTranslations } from "../support/load_translations";

describe("<AddCommentForm commentsMaxLength={commentsMaxLength} />", () => {
  let session: any = null;
  const commentsMaxLength: number = 1000;
  const commentable = {
    id: "1",
    type: "Decidim::DummyResources::DummyResource"
  };
  const orderBy = "older";
  const addCommentStub = (): any => {
    return null;
  };

  beforeEach(() => {
    loadLocaleTranslations("en");
    session = {
      user: generateUserData(),
      verifiedUserGroups: []
    };
    window.DecidimComments = {
      assets: {
        "icons.svg": "/assets/icons.svg"
      }
    };

    window.$ = $;
  });

  it("should render a div with class add-comment", () => {
    const wrapper = shallow(<AddCommentForm commentsMaxLength={commentsMaxLength} addComment={addCommentStub} session={session} commentable={commentable} rootCommentable={commentable} orderBy={orderBy} />);
    expect(wrapper.find("div.add-comment")).toBeDefined();
  });

  it("should have a reference to body textarea", () => {
    const wrapper = mount(<AddCommentForm commentsMaxLength={commentsMaxLength} addComment={addCommentStub} session={session} commentable={commentable} rootCommentable={commentable} orderBy={orderBy} />);
    expect((wrapper.instance() as AddCommentForm).bodyTextArea).toBeDefined();
  });

  it("should initialize with a state property disabled as true", () => {
    const wrapper = mount(<AddCommentForm commentsMaxLength={commentsMaxLength} addComment={addCommentStub} session={session} commentable={commentable} rootCommentable={commentable} orderBy={orderBy} />);
    expect(wrapper.state()).toHaveProperty("disabled", true);
  });

  it("should have a default prop showTitle as true", () => {
    const wrapper = mount(<AddCommentForm commentsMaxLength={commentsMaxLength} addComment={addCommentStub} session={session} commentable={commentable} rootCommentable={commentable} orderBy={orderBy} />);
    expect(wrapper.props()).toHaveProperty("showTitle", true);
  });

  it("should not render the title if prop showTitle is false", () => {
    const wrapper = shallow(<AddCommentForm commentsMaxLength={commentsMaxLength} addComment={addCommentStub} session={session} commentable={commentable} showTitle={false} rootCommentable={commentable} orderBy={orderBy} />);
    expect(wrapper.find("h4.section-heading").exists()).toBeFalsy();
  });

  it("should have a default prop submitButtonClassName as 'button button--sc'", () => {
    const wrapper = mount(<AddCommentForm commentsMaxLength={commentsMaxLength} addComment={addCommentStub} session={session} commentable={commentable} rootCommentable={commentable} orderBy={orderBy} />);
    expect(wrapper.props()).toHaveProperty("submitButtonClassName", "button button--sc");
  });

  it("should use prop submitButtonClassName as a className prop for submit button", () => {
    const wrapper = shallow(<AddCommentForm commentsMaxLength={commentsMaxLength} addComment={addCommentStub} session={session} commentable={commentable} submitButtonClassName="button small hollow" rootCommentable={commentable} orderBy={orderBy} />);
    expect(wrapper.find('button[type="submit"]').hasClass("button")).toBeTruthy();
    expect(wrapper.find('button[type="submit"]').hasClass("small")).toBeTruthy();
    expect(wrapper.find('button[type="submit"]').hasClass("hollow")).toBeTruthy();
  });

  it("should enable the submit button if textarea is not blank", () => {
    const wrapper = mount(<AddCommentForm commentsMaxLength={commentsMaxLength} addComment={addCommentStub} session={session} commentable={commentable} rootCommentable={commentable} orderBy={orderBy} />);
    wrapper.find("textarea").simulate("change", {
      target: {
        value: "This is a comment"
      }
    });
    expect(wrapper.find('button[type="submit"]').props()).not.toHaveProperty("disabled", true);
  });

  it("should disable the submit button if textarea is blank", () => {
    const wrapper = mount(<AddCommentForm commentsMaxLength={commentsMaxLength} addComment={addCommentStub} session={session} commentable={commentable} rootCommentable={commentable} orderBy={orderBy} />);
    wrapper.find("textarea").simulate("change", {
      target: {
        value: "This will be deleted"
      }
    });
    wrapper.find("textarea").simulate("change", {
      target: {
        value: ""
      }
    });
    expect(wrapper.find('button[type="submit"]').props()).toHaveProperty("disabled", true);
  });

  it("should not render a div with class 'opinion-toggle'", () => {
    const wrapper = shallow(<AddCommentForm commentsMaxLength={commentsMaxLength} addComment={addCommentStub} session={session} commentable={commentable} rootCommentable={commentable} orderBy={orderBy} />);
    expect(wrapper.find(".opinion-toggle").exists()).toBeFalsy();
  });

  it("should render the remaining character count", () => {
    const wrapper = shallow(<AddCommentForm commentsMaxLength={commentsMaxLength} addComment={addCommentStub} session={session} commentable={commentable} rootCommentable={commentable} orderBy={orderBy} />);
    const commentBody = "This is a new comment!";
    wrapper.find("textarea").simulate("change", {
      target: {
        value: commentBody
      }
    });
    expect(wrapper.find(".remaining-character-count").text()).toContain(commentsMaxLength - commentBody.length);
  });

  describe("submitting the form", () => {
    let addComment: jasmine.Spy;
    let onCommentAdded: jasmine.Spy ;
    let wrapper: ReactWrapper<any, {}>;
    let message: any = null;

    beforeEach(() => {
      addComment = jasmine.createSpy("addComment");
      onCommentAdded = jasmine.createSpy("onCommentAdded");
      wrapper = mount(<AddCommentForm commentsMaxLength={commentsMaxLength} addComment={addComment} session={session} commentable={commentable} onCommentAdded={onCommentAdded} rootCommentable={commentable} orderBy={orderBy} />);
      message = "This will be submitted";
      (wrapper.instance() as AddCommentForm).bodyTextArea.value = message;
    });

    it("should call addComment prop with the textarea value and state property alignment", () => {
      wrapper.find("form").simulate("submit");
      expect(addComment).toHaveBeenCalledWith({ body: message, alignment: 0 });
    });

    it("should reset textarea", () => {
      wrapper.find("form").simulate("submit");
      expect((wrapper.instance() as AddCommentForm).bodyTextArea.value).toBe("");
    });

    it("should prevent default form submission", () => {
      const preventDefault = jasmine.createSpy("preventDefault");
      wrapper.find("form").simulate("submit", { preventDefault });
      expect(preventDefault).toHaveBeenCalled();
    });

    it("should call the prop onCommentAdded function", () => {
      wrapper.find("form").simulate("submit");
      expect(onCommentAdded).toHaveBeenCalled();
    });
  });

  it("should initialize state with a property alignment and value 0", () => {
    const wrapper = shallow(<AddCommentForm commentsMaxLength={commentsMaxLength} addComment={addCommentStub} session={session} commentable={commentable} arguable={true} rootCommentable={commentable} orderBy={orderBy} />);
    expect(wrapper.state()).toHaveProperty("alignment", 0);
  });

  describe("when receiving an optional prop arguable with value true", () => {
    it("should render a div with class 'opinion-toggle'", () => {
      const wrapper = shallow(<AddCommentForm commentsMaxLength={commentsMaxLength} addComment={addCommentStub} session={session} commentable={commentable} arguable={true} rootCommentable={commentable} orderBy={orderBy} />);
      expect(wrapper.find(".opinion-toggle")).toBeDefined();
    });

    it("should set state alignment to 1 if user clicks ok button and change its class", () => {
      const wrapper = shallow(<AddCommentForm commentsMaxLength={commentsMaxLength} addComment={addCommentStub} session={session} commentable={commentable} arguable={true} rootCommentable={commentable} orderBy={orderBy} />);
      wrapper.find(".opinion-toggle--ok").simulate("click");
      expect(wrapper.find(".opinion-toggle--ok").hasClass("is-active")).toBeTruthy();
      expect(wrapper.state()).toHaveProperty("alignment", 1);
    });

    it("should set state alignment to -11 if user clicks ko button and change its class", () => {
      const wrapper = shallow(<AddCommentForm commentsMaxLength={commentsMaxLength} addComment={addCommentStub} session={session} commentable={commentable} arguable={true} rootCommentable={commentable} orderBy={orderBy} />);
      wrapper.find(".opinion-toggle--ko").simulate("click");
      expect(wrapper.find(".opinion-toggle--ko").hasClass("is-active")).toBeTruthy();
      expect(wrapper.state()).toHaveProperty("alignment", -1);
    });

    describe("submitting the form", () => {
      let wrapper: ReactWrapper<any, {}>;
      let addComment: jasmine.Spy;
      let message: string;

      beforeEach(() => {
        addComment = jasmine.createSpy("addComment");
        wrapper = mount(<AddCommentForm commentsMaxLength={commentsMaxLength} addComment={addComment} session={session} commentable={commentable} arguable={true} rootCommentable={commentable} orderBy={orderBy} />);
        message = "This will be submitted";
        (wrapper.instance() as AddCommentForm).bodyTextArea.value = message;
      });

      it("should call addComment prop with the state's property alignment", () => {
        wrapper.find("button.opinion-toggle--ko").simulate("click");
        wrapper.find("form").simulate("submit");
        expect(addComment).toHaveBeenCalledWith({ body: message, alignment: -1 });
      });

      it("should reset the state to its initial state", () => {
        wrapper.find("button.opinion-toggle--ok").simulate("click");
        wrapper.find("form").simulate("submit");
        expect(wrapper.state()).toHaveProperty("alignment", 0);
      });
    });
  });

  describe("when user groups are greater than 0", () => {
    beforeEach(() => {
      session.verifiedUserGroups = [
        generateUserGroupData(),
        generateUserGroupData()
      ];
    });

    it("should have a reference to user_group_id select", () => {
      const wrapper = mount(<AddCommentForm commentsMaxLength={commentsMaxLength} addComment={addCommentStub} session={session} commentable={commentable} rootCommentable={commentable} orderBy={orderBy} />);
      expect((wrapper.instance() as AddCommentForm).userGroupIdSelect).toBeDefined();
    });

    it("should render a select with option tags for each verified user group", () => {
      const wrapper = mount(<AddCommentForm commentsMaxLength={commentsMaxLength} addComment={addCommentStub} session={session} commentable={commentable} rootCommentable={commentable} orderBy={orderBy} />);
      expect(wrapper.find("select").children("option").length).toBe(3);
    });

    describe("submitting the form", () => {
      let addComment: jasmine.Spy;
      let wrapper: ReactWrapper<any, {}>;
      let message: string;
      let userGroupId: string;

      beforeEach(() => {
        addComment = jasmine.createSpy("addComment");
        wrapper = mount(<AddCommentForm commentsMaxLength={commentsMaxLength} addComment={addComment} session={session} commentable={commentable} rootCommentable={commentable} orderBy={orderBy} />);
        message = "This will be submitted";
        userGroupId = session.verifiedUserGroups[1].id;
        (wrapper.instance() as AddCommentForm).bodyTextArea.value = message;
        (wrapper.instance() as AddCommentForm).userGroupIdSelect.value = userGroupId;
      });

      it("should call addComment prop with the body textarea, alignment and user_group_id select values", () => {
        wrapper.find("form").simulate("submit");
        expect(addComment).toHaveBeenCalledWith({ body: message, alignment: 0, userGroupId });
      });

      describe("when user_group_id is blank", () => {
        beforeEach(() => {
          (wrapper.instance() as AddCommentForm).userGroupIdSelect.value = "";
        });

        it("should call addComment prop with the body textarea and alignment", () => {
          wrapper.find("form").simulate("submit");
          expect(addComment).toHaveBeenCalledWith({ body: message, alignment: 0 });
        });
      });
    });
  });

  describe("when session is null", () => {
    beforeEach(() => {
      session = null;
    });

    it("display a message to sign in or sign up", () => {
      const wrapper = mount(<AddCommentForm commentsMaxLength={commentsMaxLength} addComment={addCommentStub} session={session} commentable={commentable} rootCommentable={commentable} orderBy={orderBy} />);
      expect(wrapper.find("span").text()).toContain("sign up");
    });
  });
});
