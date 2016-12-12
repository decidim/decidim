import { shallow }           from 'enzyme';
import { filter }            from 'graphql-anywhere';
import gql                   from 'graphql-tag';

import CommentThread         from './comment_thread.component';
import Comment               from './comment.component';

import commentThreadFragment from './comment_thread.fragment.graphql'

import stubComponent         from '../support/stub_component';
import generateCommentsData  from '../support/generate_comments_data';

describe('<CommentThread />', () => {
  let comment = {};

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

    comment = filter(fragment, commentsData[0]);
  });

  it("should render a h6 comment-thread__title with author name", () => {
    const wrapper = shallow(<CommentThread comment={comment} />);
    expect(wrapper.find('h6.comment-thread__title')).to.have.text(`Conversation with ${comment.author.name}`);
  });

  it("should render a Comment and pass filter comment data as a prop to it", () => {
    const wrapper = shallow(<CommentThread comment={comment} />);
    expect(wrapper.find(Comment).first()).to.have.prop("comment").deep.equal(filter(commentFragment, comment));
  });
});
