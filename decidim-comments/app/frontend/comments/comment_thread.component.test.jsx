import { shallow }             from 'enzyme';
import { filter }              from 'graphql-anywhere';
import gql                     from 'graphql-tag';

import CommentThread         from './comment_thread.component';
import Comment               from './comment.component';

import commentThreadFragment from './comment_thread.fragment.graphql'

import stubComponent         from '../support/stub_component';
import generateCommentsData  from '../support/generate_comments_data';
import generateCUserData     from '../support/generate_user_data';

describe('<CommentThread />', () => {
  let comment = {};
  let session = null;

  const commentFragment = gql`
    fragment Comment on Comment {
      body
    }
  `;

  stubComponent(Comment, {
    fragments: {
      comment: commentFragment
    }
  });

  beforeEach(() => {
    const commentsData = generateCommentsData(1);

    const fragment = gql`
      ${commentThreadFragment}
      ${commentFragment}
    `;

    session = {
      user: generateCUserData()
    };
    comment = filter(fragment, commentsData[0]);
  });

  describe("when comment doesn't have replies", () => {
    it("should not render a title with author name", () => {
      const wrapper = shallow(<CommentThread comment={comment} session={session} />);
      expect(wrapper.find('h6.comment-thread__title')).not.to.present();
    });
  });

  describe("when comment does have replies", () => {
    beforeEach(() => {
      comment.hasReplies = true;
    });

    it("should render a h6 comment-thread__title with author name", () => {
      const wrapper = shallow(<CommentThread comment={comment} session={session} />);
      expect(wrapper.find('h6.comment-thread__title')).to.have.text(`Conversation with ${comment.author.name}`);
    });
  });

  describe("should render a Comment", () => {
    it("and pass the session as a prop to it", () => {
      const wrapper = shallow(<CommentThread comment={comment} session={session} />);
      expect(wrapper.find(Comment).first()).to.have.prop("session").deep.equal(session);
    });

    it("and pass filter comment data as a prop to it", () => {
      const wrapper = shallow(<CommentThread comment={comment} session={session} />);
      expect(wrapper.find(Comment).first()).to.have.prop("comment").deep.equal(filter(commentFragment, comment));
    });

    it("and pass the votable as a prop to it", () => {
      const wrapper = shallow(<CommentThread comment={comment} session={session} votable />);
      expect(wrapper.find(Comment).first()).to.have.prop("votable").equal(true);
    });

    it("and pass the isRootComment equal true", () => {
      const wrapper = shallow(<CommentThread comment={comment} session={session} votable isRootComment />);
      expect(wrapper.find(Comment).first()).to.have.prop("isRootComment").equal(true);
    });
  });
});
