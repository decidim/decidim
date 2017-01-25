/* eslint-disable no-unused-expressions */
import { shallow, mount }   from 'enzyme';
import { filter }           from 'graphql-anywhere';
import gql                  from 'graphql-tag';

import Comment              from './comment.component';
import AddCommentForm       from './add_comment_form.component';
import UpVoteButton         from './up_vote_button.component';
import DownVoteButton       from './down_vote_button.component';

import commentFragment      from './comment.fragment.graphql';
import commentDataFragment  from './comment_data.fragment.graphql';
import upVoteFragment       from './up_vote.fragment.graphql';
import downVoteFragment     from './down_vote.fragment.graphql';

import stubComponent        from '../support/stub_component';
import generateCommentsData from '../support/generate_comments_data';
import generateUserData     from '../support/generate_user_data';

describe("<Comment />", () => {
  let comment = {};
  let session = null;

  stubComponent(AddCommentForm);
  stubComponent(UpVoteButton);
  stubComponent(DownVoteButton);

  beforeEach(() => {
    let commentsData = generateCommentsData(1);
    commentsData[0].replies = generateCommentsData(3);

    const fragment = gql`
      ${commentFragment}
      ${commentDataFragment}
      ${upVoteFragment}
      ${downVoteFragment}
    `;

    comment = filter(fragment, commentsData[0]);
    session = {
      user: generateUserData()
    }
  });

  it("should render an article with class comment", () => {
    const wrapper = shallow(<Comment comment={comment} session={session} />);
    expect(wrapper.find('article.comment')).to.present();
  });

  it("should render a time tag with comment's created at", () => {
    const wrapper = shallow(<Comment comment={comment} session={session} />);
    expect(wrapper.find('time')).to.have.text(comment.created_at);
  });

  it("should render author's name in a link with class author__name", () => {
    const wrapper = shallow(<Comment comment={comment} session={session} />);
    expect(wrapper.find('a.author__name')).to.have.text(comment.author.name);
  });

  it("should render author's avatar as a image tag", () => {
    const wrapper = shallow(<Comment comment={comment} session={session} />);
    expect(wrapper.find('a.author__avatar img')).to.have.attr('src').equal(comment.author.avatarUrl);
  });

  it("should render comment's body on a div with class comment__content", () => {
    const wrapper = shallow(<Comment comment={comment} session={session} />);
    expect(wrapper.find('div.comment__content')).to.have.text(comment.body);
  });

  it("should initialize with a state property showReplyForm as false", () => {
    const wrapper = shallow(<Comment comment={comment} session={session} />);
    expect(wrapper).to.have.state('showReplyForm', false);
  });

  it("should render a AddCommentForm component with the correct props when clicking the reply button", () => {
    const wrapper = shallow(<Comment comment={comment} session={session} />);
    expect(wrapper.find(AddCommentForm)).not.to.be.present();
    wrapper.find('button.comment__reply').simulate('click');
    expect(wrapper.find(AddCommentForm)).to.have.prop('session').deep.equal(session);
    expect(wrapper.find(AddCommentForm)).to.have.prop('commentableId').equal(comment.id);
    expect(wrapper.find(AddCommentForm)).to.have.prop('commentableType').equal("Decidim::Comments::Comment");
    expect(wrapper.find(AddCommentForm)).to.have.prop('showTitle').equal(false);
    expect(wrapper.find(AddCommentForm)).to.have.prop('submitButtonClassName').equal('button small hollow');
  });

  it("should not render the reply button if the comment cannot have replies", () => {
    comment.canHaveReplies = false;
    const wrapper = shallow(<Comment comment={comment} session={session} />);
    expect(wrapper.find('button.comment__reply')).not.to.be.present();
  });

  it("should not render the additional reply button if the parent comment has no replies and isRootcomment", () => {
    comment.canHaveReplies = true;
    comment.hasReplies = false;
    const wrapper = shallow(<Comment comment={comment} session={session} isRootComment />);
    expect(wrapper.find('div.comment__additionalreply')).not.to.be.present();
  });

 it("should not render the additional reply button if the parent comment has replies and not isRootcomment", () => {
    comment.canHaveReplies = true;
    comment.hasReplies = true;
    const wrapper = shallow(<Comment comment={comment} session={session} />);
    expect(wrapper.find('div.comment__additionalreply')).not.to.be.present();
  });

  it("should render the additional reply button if the parent comment has replies and isRootcomment", () => {
    comment.canHaveReplies = true;
    comment.hasReplies = true;
    const wrapper = shallow(<Comment comment={comment} session={session} isRootComment />);
    expect(wrapper.find('div.comment__additionalreply')).to.be.present();
  });

  it("should render comment replies a separate Comment components", () => {
    const wrapper = shallow(<Comment comment={comment} session={session} votable />);
    wrapper.find(Comment).forEach((node, idx) => {
      expect(node).to.have.prop("comment").deep.equal(comment.replies[idx]);
      expect(node).to.have.prop("session").deep.equal(session);
      expect(node).to.have.prop("articleClassName").equal("comment comment--nested")
      expect(node).to.have.prop("votable").equal(true);
    });
  });

  it("should render comment replies with articleClassName as 'comment comment--nested comment--nested--alt' when articleClassName is 'comment comment--nested'", () => {
    const wrapper = shallow(<Comment comment={comment} session={session} articleClassName="comment comment--nested" />);
    wrapper.find(Comment).forEach((node) => {
      expect(node).to.have.prop("articleClassName").equal("comment comment--nested comment--nested--alt")
    });
  });

  it("should have a default prop articleClassName with value 'comment'", () => {
    const wrapper = mount(<Comment comment={comment} session={session} />);
    expect(wrapper).to.have.prop("articleClassName").equal("comment");
  });

  it("should have a default prop isRootComment with value false", () => {
    const wrapper = mount(<Comment comment={comment} session={session} />);
    expect(wrapper).to.have.prop("isRootComment").equal(false);
  });

  describe("when user is not logged in", () => {
    beforeEach(() => {
      session = null;
    });

    it("should not render reply button", () => {
      const wrapper = shallow(<Comment comment={comment} session={session} />);
      expect(wrapper.find('button.comment__reply')).not.to.be.present();
    });
  });

  it("should render a 'in favor' badge if comment's alignment is 1", () => {
    comment.alignment = 1;
    const wrapper = shallow(<Comment comment={comment} session={session} />);
    expect(wrapper.find('span.success.label')).to.have.text('In favor');
  });

  it("should render a 'against' badge if comment's alignment is -1", () => {
    comment.alignment = -1;
    const wrapper = shallow(<Comment comment={comment} session={session} />);
    expect(wrapper.find('span.alert.label')).to.have.text('Against');
  });

  describe("when the comment is votable", () => {
    it("should render an UpVoteButton component", () => {
      const wrapper = shallow(<Comment comment={comment} session={session} votable />);
      expect(wrapper.find(UpVoteButton)).to.have.prop("comment").deep.equal(comment);
    })

    it("should render an DownVoteButton component", () => {
      const wrapper = shallow(<Comment comment={comment} session={session} votable />);
      expect(wrapper.find(DownVoteButton)).to.have.prop("comment").deep.equal(comment);
    })
  });
});
