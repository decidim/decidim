import { shallow }             from 'enzyme';
import { filter }              from 'graphql-anywhere';
import gql                     from 'graphql-tag';

import CommentThread           from './comment_thread.component';
import Comment                 from './comment.component';

import commentThreadFragment   from './comment_thread.fragment.graphql'

import stubComponent           from '../support/stub_component';
import generateCommentsData    from '../support/generate_comments_data';
import generateCurrentUserData from '../support/generate_current_user_data';

describe('<CommentThread />', () => {
  let comment = {};
  let currentUser = null;

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

    currentUser = generateCurrentUserData();
    comment = filter(fragment, commentsData[0]);
  });

  describe("when comment doesn't have replies", () => {
    it("should not render a title with author name", () => {
      const wrapper = shallow(<CommentThread comment={comment} currentUser={currentUser} />);
      expect(wrapper.find('h6.comment-thread__title')).not.to.present();
    });
  });

  describe("when comment does have replies", () => {
    beforeEach(() => {
      comment.replies = generateCommentsData(3);  
    });

    it("should render a h6 comment-thread__title with author name", () => {
      const wrapper = shallow(<CommentThread comment={comment} currentUser={currentUser} />);
      expect(wrapper.find('h6.comment-thread__title')).to.have.text(`Conversation with ${comment.author.name}`);
    });
  });

  describe("should render a Comment", () => {
    it("and pass the currentUser as a prop to it", () => {
      const wrapper = shallow(<CommentThread comment={comment} currentUser={currentUser} />);
      expect(wrapper.find(Comment).first()).to.have.prop("currentUser").deep.equal(currentUser);
    });

    it("and pass filter comment data as a prop to it", () => {
      const wrapper = shallow(<CommentThread comment={comment} currentUser={currentUser} />);
      expect(wrapper.find(Comment).first()).to.have.prop("comment").deep.equal(filter(commentFragment, comment));
    });  
  });
});
