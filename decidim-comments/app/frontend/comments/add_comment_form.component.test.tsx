import { mount, ReactWrapper, shallow } from "enzyme";

import * as React from "react";

import { AddCommentForm } from "./add_comment_form.component";

import generateUserData from "../support/generate_user_data";
import generateUserGroupData from "../support/generate_user_group_data";
import { loadLocaleTranslations } from "../support/load_translations";

describe("<AddCommentForm />", () => {
  let session: any = null;
  const commentable = {
    id: "1",
    type: "Decidim::DummyResource",
  };
  const addCommentStub = (): any => {
    return null;
  };

  beforeEach(() => {
    loadLocaleTranslations("en");
    session = {
      user: generateUserData(),
      verifiedUserGroups: [],
    };
    window.DecidimComments = {
      assets: {
        "icons.svg": "/assets/icons.svg",
      },
    };
  });

  it("should render a div with class add-comment", () => {
    const wrapper = shallow(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} />);
    expect(wrapper.find("div.add-comment")).toBeDefined();
  });

  it("should have a reference to body textarea", () => {
    const wrapper = mount(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} />);
    expect((wrapper.instance() as AddCommentForm).bodyTextArea).toBeDefined();
  });

  it("should initialize with a state property disabled as true", () => {
    const wrapper = mount(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} />);
    expect(wrapper.state()).toHaveProperty("disabled", true);
  });

  it("should have a default prop showTitle as true", () => {
    const wrapper = mount(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} />);
    expect(wrapper.props()).toHaveProperty("showTitle", true);
  });

  it("should not render the title if prop showTitle is false", () => {
    const wrapper = shallow(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} showTitle={false} />);
    expect(wrapper.find("h5.section-heading").exists()).toBeFalsy();
  });

  it("should have a default prop submitButtonClassName as 'button button--sc'", () => {
    const wrapper = mount(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} />);
    expect(wrapper.props()).toHaveProperty("submitButtonClassName", "button button--sc");
  });

  it("should have a default prop maxLength of 1000", () => {
    const wrapper = mount(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} />);
    expect(wrapper.props()).toHaveProperty("maxLength", 1000);
  });

  it("should use prop submitButtonClassName as a className prop for submit button", () => {
    const wrapper = shallow(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} submitButtonClassName="button small hollow" />);
    expect(wrapper.find('button[type="submit"]').hasClass("button")).toBeTruthy();
    expect(wrapper.find('button[type="submit"]').hasClass("small")).toBeTruthy();
    expect(wrapper.find('button[type="submit"]').hasClass("hollow")).toBeTruthy();
  });

  it("should enable the submit button if textarea is not blank", () => {
    const wrapper = mount(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} />);
    wrapper.find("textarea").simulate("change", {
      target: {
        value: "This is a comment",
      },
    });
    expect(wrapper.find('button[type="submit"]').props()).not.toHaveProperty("disabled", true);
  });

  it("should disable the submit button if textarea is blank", () => {
    const wrapper = mount(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} />);
    wrapper.find("textarea").simulate("change", {
      target: {
        value: "This will be deleted",
      },
    });
    wrapper.find("textarea").simulate("change", {
      target: {
        value: "",
      },
    });
    expect(wrapper.find('button[type="submit"]').props()).toHaveProperty("disabled", true);
  });

  it("should not render a div with class 'opinion-toggle'", () => {
    const wrapper = shallow(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} />);
    expect(wrapper.find(".opinion-toggle").exists()).toBeFalsy();
  });

  describe("submitting the form", () => {
    let addComment: jasmine.Spy = null;
    let onCommentAdded: jasmine.Spy = null;
    let wrapper: ReactWrapper<any, {}> = null;
    let message: any = null;

    beforeEach(() => {
      addComment = jasmine.createSpy("addComment");
      onCommentAdded = jasmine.createSpy("onCommentAdded");
      wrapper = mount(<AddCommentForm addComment={addComment} session={session} commentable={commentable} onCommentAdded={onCommentAdded} />);
      message = "This will be submitted";
      (wrapper.instance() as AddCommentForm).bodyTextArea.value = message;
    });

    it("should call addComment prop with the textarea value and state property alignment", () => {
      wrapper.find("form").simulate("submit");
      expect(addComment).toHaveBeenCalledWith({ body: message, alignment: 0 });
    });

    it("should reset textarea", () => {
      wrapper.find("form").simulate("submit");
      expect((wrapper.find("textarea").get(0) as any).value).toBe("");
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
    const wrapper = shallow(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} arguable={true} />);
    expect(wrapper.state()).toHaveProperty("alignment", 0);
  });

  describe("when receiving an optional prop arguable with value true", () => {
    it("should render a div with class 'opinion-toggle'", () => {
      const wrapper = shallow(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} arguable={true} />);
      expect(wrapper.find(".opinion-toggle")).toBeDefined();
    });

    it("should set state alignment to 1 if user clicks ok button and change its class", () => {
      const wrapper = shallow(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} arguable={true} />);
      wrapper.find(".opinion-toggle--ok").simulate("click");
      expect(wrapper.find(".opinion-toggle--ok").hasClass("is-active")).toBeTruthy();
      expect(wrapper.state()).toHaveProperty("alignment", 1);
    });

    it("should set state alignment to -11 if user clicks ko button and change its class", () => {
      const wrapper = shallow(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} arguable={true} />);
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
        wrapper = mount(<AddCommentForm addComment={addComment} session={session} commentable={commentable} arguable={true} />);
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
        generateUserGroupData(),
      ];
    });

    it("should have a reference to user_group_id select", () => {
      const wrapper = mount(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} />);
      expect((wrapper.instance() as AddCommentForm).userGroupIdSelect).toBeDefined();
    });

    it("should render a select with option tags for each verified user group", () => {
      const wrapper = mount(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} />);
      expect(wrapper.find("select").children("option").length).toBe(3);
    });

    describe("submitting the form", () => {
      let addComment: jasmine.Spy;
      let wrapper: ReactWrapper<any, {}>;
      let message: string;
      let userGroupId: string;

      beforeEach(() => {
        addComment = jasmine.createSpy("addComment");
        wrapper = mount(<AddCommentForm addComment={addComment} session={session} commentable={commentable} />);
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
      const wrapper = mount(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} />);
      expect(wrapper.find("span").text()).toContain("sign up");
    });
  });
});
