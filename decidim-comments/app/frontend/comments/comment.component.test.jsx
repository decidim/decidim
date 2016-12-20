/* eslint-disable no-unused-expressions */
import { shallow, mount }      from 'enzyme';
import { filter }              from 'graphql-anywhere';
import gql                     from 'graphql-tag';

import { Comment }             from './comment.component';
import AddCommentForm          from './add_comment_form.component';

import commentFragment         from './comment.fragment.graphql';
import commentDataFragment     from './comment_data.fragment.graphql';

import stubComponent           from '../support/stub_component';
import generateCommentsData    from '../support/generate_comments_data';
import generateCurrentUserData from '../support/generate_current_user_data';

describe("<Comment />", () => {
  let comment = {};
  let currentUser = null;
  const upVote = sinon.spy();
  const downVote = sinon.spy();

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
    const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} upVote={upVote} downVote={downVote} />);
    expect(wrapper.find('article.comment')).to.present();
  });

  it("should render a time tag with comment's created at", () => {
    const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} upVote={upVote} downVote={downVote} />);
    expect(wrapper.find('time')).to.have.text(comment.created_at);
  });

  it("should render author's name in a link with class author__name", () => {
    const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} upVote={upVote} downVote={downVote} />);
    expect(wrapper.find('a.author__name')).to.have.text(comment.author.name);
  });

  it("should render author's avatar as a image tag", () => {
    const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} upVote={upVote} downVote={downVote} />);
    expect(wrapper.find('a.author__avatar img')).to.have.attr('src').equal(comment.author.avatarUrl);
  });

  it("should render comment's body on a div with class comment__content", () => {
    const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} upVote={upVote} downVote={downVote} />);
    expect(wrapper.find('div.comment__content')).to.have.text(comment.body);
  });

  it("should initialize with a state property showReplyForm as false", () => {
    const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} upVote={upVote} downVote={downVote} />);
    expect(wrapper).to.have.state('showReplyForm', false);
  });

  it("should render a AddCommentForm component with the correct props when clicking the reply button", () => {
    const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} upVote={upVote} downVote={downVote} />);
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
    const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} upVote={upVote} downVote={downVote} />);
    expect(wrapper.find('button.comment__reply')).not.to.be.present();
  });

  it("should render comment replies a separate Comment components", () => {
    const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} upVote={upVote} downVote={downVote} votable />);
    wrapper.find(Comment).forEach((node, idx) => {
      expect(node).to.have.prop("comment").deep.equal(comment.replies[idx]);
      expect(node).to.have.prop("currentUser").deep.equal(currentUser);
      expect(node).to.have.prop("articleClassName").equal("comment comment--nested")
      expect(node).to.have.prop("votable").equal(true);
    });
  });

  it("should render comment replies with articleClassName as 'comment comment--nested comment--nested--alt' when articleClassName is 'comment comment--nested'", () => {
    const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} upVote={upVote} downVote={downVote} articleClassName="comment comment--nested" />);
    wrapper.find(Comment).forEach((node) => {
      expect(node).to.have.prop("articleClassName").equal("comment comment--nested comment--nested--alt")
    });
  });

  it("should have a default prop articleClassName with value 'comment'", () => {
    const wrapper = mount(<Comment comment={comment} currentUser={currentUser} upVote={upVote} downVote={downVote} />);
    expect(wrapper).to.have.prop("articleClassName").equal("comment");
  });

  describe("when user is not logged in", () => {
    beforeEach(() => {
      currentUser = null;
    });

    it("should not render reply button", () => {
      const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} upVote={upVote} downVote={downVote} />);
      expect(wrapper.find('button.comment__reply')).not.to.be.present();
    });
  });

  it("should render a 'in favor' badge if comment's alignment is 1", () => {
    comment.alignment = 1;
    const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} upVote={upVote} downVote={downVote} />);
    expect(wrapper.find('span.success.label')).to.have.text('In favor');
  });

  it("should render a 'against' badge if comment's alignment is -1", () => {
    comment.alignment = -1;
    const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} upVote={upVote} downVote={downVote} />);
    expect(wrapper.find('span.alert.label')).to.have.text('Against');
  });

  describe("when the comment is votable", () => {
    it("should render a link to upVote comments", () => {
      const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} upVote={upVote} downVote={downVote} votable />);
      expect(wrapper.find('.comment__votes--up')).to.be.present();
    });

    it("should render the number of comment's upVotes", () => {
      const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} upVote={upVote} downVote={downVote} votable />);
      expect(wrapper.find('.comment__votes--up')).to.contain.text(comment.upVotes);
    });

    it("should call the upVote prop when the .comment__votes--up is clicked", () => {
      const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} upVote={upVote} downVote={downVote} votable />);
      wrapper.find('.comment__votes--up').simulate('click');
      expect(upVote).to.have.been.called;
    });

    it("should render a link to downVote comments", () => {
      const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} upVote={upVote} downVote={downVote} votable />);
      expect(wrapper.find('.comment__votes--down')).to.be.present();
    });

    it("should render the number of comment's downVotes", () => {
      const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} upVote={upVote} downVote={downVote} votable />);
      expect(wrapper.find('.comment__votes--down')).to.contain.text(comment.downVotes);
    });

    it("should call the upVote prop when the .comment__votes--down is clicked", () => {
      const wrapper = shallow(<Comment comment={comment} currentUser={currentUser} upVote={upVote} downVote={downVote} votable />);
      wrapper.find('.comment__votes--up').simulate('click');
      expect(upVote).to.have.been.called;
    });
  });
});
