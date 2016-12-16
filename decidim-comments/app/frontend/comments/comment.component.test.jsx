import { shallow, mount }      from 'enzyme';
import { filter }              from 'graphql-anywhere';
import gql                     from 'graphql-tag';

import Comment                 from './comment.component';
import AddCommentForm          from './add_comment_form.component';

import commentFragment         from './comment.fragment.graphql';
import commentDataFragment     from './comment_data.fragment.graphql';

import stubComponent           from '../support/stub_component';
import generateCommentsData    from '../support/generate_comments_data';
import generateCurrentUserData from '../support/generate_current_user_data';

describe("<Comment />", () => {
  let comment = {};
  let currentUser = null;

  stubComponent(AddCommentForm);

  beforeEach(() => {
    let commentsData = generateCommentsData(1);
    commentsData[0].replies = generateCommentsData(3);
    const currentUserData = generateCurrentUserData();
    
    const fragment = gql`
      ${commentFragment}
      ${commentDataFragment}
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

  it("should render author's avatar as a image tag", () => {
    const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} />);
    expect(wrapper.find('a.author__avatar img')).to.have.attr('src').equal(comment.author.avatarUrl);
  });

  it("should render comment's body on a div with class comment__content", () => {
    const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} />);
    expect(wrapper.find('div.comment__content')).to.have.text(comment.body);
  });

  it("should initialize with a state property showReplyForm as false", () => {
    const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} />);
    expect(wrapper).to.have.state('showReplyForm', false);
  });

  it("should render a AddCommentForm component with the correct props when clicking the reply button", () => {
    const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} />);
    expect(wrapper.find(AddCommentForm)).not.to.be.present();
    wrapper.find('button.comment__reply').simulate('click');
    expect(wrapper.find(AddCommentForm)).to.have.prop('currentUser').deep.equal(currentUser);
    expect(wrapper.find(AddCommentForm)).to.have.prop('commentableId').equal(comment.id);
    expect(wrapper.find(AddCommentForm)).to.have.prop('commentableType').equal("Decidim::Comments::Comment");
    expect(wrapper.find(AddCommentForm)).to.have.prop('showTitle').equal(false);
    expect(wrapper.find(AddCommentForm)).to.have.prop('submitButtonClassName').equal('button small hollow');
  });

  it("should not render the reply button if the comment cannot have replies", () => {
    comment.canHaveReplies = false;
    const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} />);
    expect(wrapper.find('button.comment__reply')).not.to.be.present();
  });

  it("should render comment replies a separate Comment components", () => {
    const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} />);
    wrapper.find(Comment).forEach((node, idx) => {
      expect(node).to.have.prop("comment").deep.equal(comment.replies[idx]);
      expect(node).to.have.prop("currentUser").deep.equal(currentUser);
      expect(node).to.have.prop("articleClassName").equal("comment comment--nested")
    });
  });

  it("should render comment replies with articleClassName as 'comment comment--nested comment--nested--alt' when articleClassName is 'comment comment--nested'", () => {
    const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} articleClassName="comment comment--nested" />);
    wrapper.find(Comment).forEach((node) => {
      expect(node).to.have.prop("articleClassName").equal("comment comment--nested comment--nested--alt")
    });
  });

  it("should have a default prop articleClassName with value 'comment'", () => {
    const wrapper = mount(<Comment comment={comment} currentUser={currentUser} />);
    expect(wrapper).to.have.prop("articleClassName").equal("comment");
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
