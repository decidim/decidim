import { shallow }             from 'enzyme';
import { filter }              from 'graphql-anywhere';
import gql                     from 'graphql-tag';

import Comment                 from './comment.component';
import AddCommentForm          from './add_comment_form.component';

import commentFragment         from './comment.fragment.graphql'

import stubComponent           from '../support/stub_component';
import generateCommentsData    from '../support/generate_comments_data';
import generateCurrentUserData from '../support/generate_current_user_data';

describe("<Comment currentUser={currentUser} />", () => {
  let comment = {};
  let currentUser = null;

  stubComponent(AddCommentForm);

  beforeEach(() => {
    const commentsData = generateCommentsData(1);
    const currentUserData = generateCurrentUserData();
    
    const fragment = gql`
      ${commentFragment}
    `;

    comment = filter(fragment, commentsData[0]);
    currentUser = currentUserData;
  });

  it("should render an article with class comment", () => {
    const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} />);
    expect(wrapper.find('article.comment')).to.present();
  });

  it("should render a time tag with comment's created at", () => {
    const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} />);
    expect(wrapper.find('time')).to.have.text(comment.created_at);
  });

  it("should render author's name in a link with class author__name", () => {
    const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} />);
    expect(wrapper.find('a.author__name')).to.have.text(comment.author.name);
  });

  it("should render author's avatar using the UserAvatar component and the author's name first letter", () => {
    const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} />);
    expect(wrapper.find('UserAvatar')).to.have.prop('name', comment.author.name[0]);
  });

  it("should render comment's body on a div with class comment__content", () => {
    const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} />);
    expect(wrapper.find('div.comment__content')).to.have.text(comment.body);
  });

  it("should initialize with a state property showReplyForm as false", () => {
    const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} />);
    expect(wrapper).to.have.state('showReplyForm', false);
  });

  it("should render a AddCommentForm component when clicking the reply button", () => {
    const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} />);
    expect(wrapper.find(AddCommentForm)).not.to.be.present();
    wrapper.find('button.comment__reply').simulate('click');
    expect(wrapper.find(AddCommentForm)).to.be.present();
  });

  describe("when user is not logged in", () => {
    beforeEach(() => {
      currentUser = null;
    });

    it("should not render reply button", () => {
      const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} />);
      expect(wrapper.find('button.comment__reply')).not.to.be.present();
    });
  });
});
