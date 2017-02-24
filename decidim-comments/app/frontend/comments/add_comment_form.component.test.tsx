import { shallow, mount }from 'enzyme';
import * as chai from 'chai-jasmine';
import * as chaiEnzyme from 'chai-enzyme';
const { expect } = chai;

import * as React from 'react';

import { AddCommentForm } from './add_comment_form.component';

import generateUserData from '../support/generate_user_data';
import generateUserGroupData from '../support/generate_user_group_data';

chai.use(chaiEnzyme());

describe("<AddCommentForm />", () => {
  let session: any = null;
  const commentable = {
    id: "1",
    type: "Decidim::DummyResource"
  };
  const addCommentStub = (): any => {
    return null;
  }

  beforeEach(() => {
    session = {
      user: generateUserData(),
      verifiedUserGroups: []
    };
  });

  it("should render a div with class add-comment", () => {
    const wrapper = shallow(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} />);
    expect(wrapper.find('div.add-comment')).to.present();
  });

  it("should have a reference to body textarea", () => {
    const wrapper = mount(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} />);
    expect((wrapper.instance() as AddCommentForm).bodyTextArea).to.be.ok;
  });

  it("should initialize with a state property disabled as true", () => {
    const wrapper = mount(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} />);
    expect(wrapper).to.have.state('disabled', true);
  });

  it("should have a default prop showTitle as true", () => {
    const wrapper = mount(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} />);
    expect(wrapper).to.have.prop('showTitle').equal(true);
  });

  it("should not render the title if prop showTitle is false", () => {
    const wrapper = shallow(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} showTitle={false} />);
    expect(wrapper.find('h5.section-heading')).not.to.be.present();
  });

  it("should have a default prop submitButtonClassName as 'button button--sc'", () => {
    const wrapper = mount(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} />);
    expect(wrapper).to.have.prop('submitButtonClassName').equal('button button--sc');
  });

  it("should have a default prop maxLength of 1000", () => {
    const wrapper = mount(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} />);
    expect(wrapper).to.have.prop('maxLength').equal(1000);
  });


  it("should use prop submitButtonClassName as a className prop for submit button", () => {
    const wrapper = shallow(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} submitButtonClassName="button small hollow" />);
    expect(wrapper.find('button[type="submit"]')).to.have.className('button');
    expect(wrapper.find('button[type="submit"]')).to.have.className('small');
    expect(wrapper.find('button[type="submit"]')).to.have.className('hollow');
  });

  it("should enable the submit button if textarea is not blank", () => {
    const wrapper = mount(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} />);
    wrapper.find('textarea').simulate('change', {
      target: {
        value: 'This is a comment'
      }
    });
    expect(wrapper.find('button[type="submit"]')).not.to.be.disabled();
  });

  it("should disable the submit button if textarea is blank", () => {
    const wrapper = mount(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} />);
    wrapper.find('textarea').simulate('change', {
      target: {
        value: 'This will be deleted'
      }
    });
    wrapper.find('textarea').simulate('change', {
      target: {
        value: ''
      }
    });
    expect(wrapper.find('button[type="submit"]')).to.be.disabled();
  });

  it("should not render a div with class 'opinion-toggle'", () => {
    const wrapper = shallow(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} />);
    expect(wrapper.find('.opinion-toggle')).not.to.be.present();
  });

  describe("submitting the form", () => {
    let addComment: jasmine.Spy = null;
    let onCommentAdded: jasmine.Spy = null;
    let wrapper: any = null;
    let message: any = null;

    beforeEach(() => {
      addComment = jasmine.createSpy('addComment');
      onCommentAdded = jasmine.createSpy('onCommentAdded');
      wrapper = mount(<AddCommentForm addComment={addComment} session={session} commentable={commentable} onCommentAdded={onCommentAdded} />);
      message = 'This will be submitted';
      wrapper.instance().bodyTextArea.value = message;
    });

    it("should call addComment prop with the textarea value and state property alignment", () => {
      wrapper.find('form').simulate('submit');
      console.log(addComment);
      expect(addComment).to.have.been.calledWith();
    });

    // it("should reset textarea", () => {
    //   wrapper.find('form').simulate('submit');
    //   expect(wrapper.find('textarea')).to.have.value('');
    // });

    // it("should prevent default form submission", () => {
    //   const preventDefault = jasmine.createSpy('preventDefault');
    //   wrapper.find('form').simulate('submit', { preventDefault });
    //   expect(preventDefault).to.have.been.called;
    // });

    // it("should call the prop onCommentAdded function", () => {
    //   wrapper.find('form').simulate('submit');
    //   expect(onCommentAdded).to.have.been.called;
    // });
  });

  // it("should initialize state with a property alignment and value 0", () => {
  //   const wrapper = shallow(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} arguable />);
  //   expect(wrapper).to.have.state('alignment').equal(0);
  // });

  // describe("when receiving an optional prop arguable with value true", () => {
  //   it("should render a div with class 'opinion-toggle'", () => {
  //     const wrapper = shallow(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} arguable />);
  //     expect(wrapper.find('.opinion-toggle')).to.be.present();
  //   });

  //   it("should set state alignment to 1 if user clicks ok button and change its class", () => {
  //     const wrapper = shallow(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} arguable />);
  //     wrapper.find('.opinion-toggle--ok').simulate('click');
  //     expect(wrapper.find('.opinion-toggle--ok')).to.have.className('is-active');
  //     expect(wrapper).to.have.state('alignment').equal(1);
  //   });

  //   it("should set state alignment to -11 if user clicks ko button and change its class", () => {
  //     const wrapper = shallow(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} arguable />);
  //     wrapper.find('.opinion-toggle--ko').simulate('click');
  //     expect(wrapper.find('.opinion-toggle--ko')).to.have.className('is-active');
  //     expect(wrapper).to.have.state('alignment').equal(-1);
  //   });

  //   describe("submitting the form", () => {
  //     let addComment: any = null;
  //     let wrapper: any = null;
  //     let message: any = null;

  //     beforeEach(() => {
  //       addComment = jasmine.createSpy('addComment');
  //       wrapper = mount(<AddCommentForm addComment={addComment} session={session} commentable={commentable} arguable />);
  //       message = 'This will be submitted';
  //       wrapper.instance().bodyTextArea.value = message;
  //     });

  //     it("should call addComment prop with the state's property alignment", () => {
  //       wrapper.find('button.opinion-toggle--ko').simulate('click');
  //       wrapper.find('form').simulate('submit');
  //       expect(addComment).to.have.been.calledWith({ body: message, alignment: -1 });
  //     });

  //     it("should reset the state to its initial state", () => {
  //       wrapper.find('button.opinion-toggle--ok').simulate('click');
  //       wrapper.find('form').simulate('submit');
  //       expect(wrapper).to.have.state('alignment').eq(0);
  //     });
  //   });
  // });

  // describe("when user groups are greater than 0", () => {
  //   beforeEach(() => {
  //     session.verifiedUserGroups = [
  //       generateUserGroupData(),
  //       generateUserGroupData()
  //     ];
  //   });

  //   it("should have a reference to user_group_id select", () => {
  //     const wrapper = mount(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} />);
  //     expect((wrapper.instance() as AddCommentForm).userGroupIdSelect).to.be.ok;
  //   });

  //   it("should render a select with option tags for each verified user group", () => {
  //     const wrapper = mount(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} />);
  //     expect(wrapper.find('select')).to.have.exactly(3).descendants('option');
  //   });

  //   describe("submitting the form", () => {
  //     let addComment: any = null;
  //     let wrapper: any = null;
  //     let message: any = null;
  //     let userGroupId: any = null;

  //     beforeEach(() => {
  //       addComment = jasmine.createSpy('addComment');
  //       wrapper = mount(<AddCommentForm addComment={addComment} session={session} commentable={commentable} />);
  //       message = 'This will be submitted';
  //       userGroupId = session.verifiedUserGroups[1].id;
  //       wrapper.instance().bodyTextArea.value = message;
  //       wrapper.instance().userGroupIdSelect.value = userGroupId;
  //     });

  //     it("should call addComment prop with the body textarea, alignment and user_group_id select values", () => {
  //       wrapper.find('form').simulate('submit');
  //       expect(addComment).to.have.been.calledWith({ body: message, alignment: 0, userGroupId });
  //     });

  //     describe("when user_group_id is blank", () => {
  //       beforeEach(() => {
  //         wrapper.instance().userGroupIdSelect.value = '';
  //       });

  //       it("should call addComment prop with the body textarea and alignment", () => {
  //         wrapper.find('form').simulate('submit');
  //         expect(addComment).to.have.been.calledWith({ body: message, alignment: 0 });
  //       });
  //     });
  //   });
  // });

  // describe("when session is null", () => {
  //   beforeEach(() => {
  //     session = null;
  //   });

  //   it("display a message to sign in or sign up", () => {
  //     const wrapper = mount(<AddCommentForm addComment={addCommentStub} session={session} commentable={commentable} />);
  //     expect(wrapper.find('span')).to.include("sign up");
  //   });
  // });
});
