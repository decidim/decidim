import { shallow }   from 'enzyme';
import { filter }    from 'graphql-anywhere';
import gql           from 'graphql-tag';

import CommentThread from './comment_thread.component';

import commentThreadFragment from './comment_thread.fragment.graphql'

describe('<CommentThread />', () => {
  let comment = {};

  beforeEach(() => {
    let commentData = {
      comment: {
        body: "Test",
        author: {
          name: "Marc Riera Casals"
        }
      }
    };

    comment = filter(gql`${commentThreadFragment}`, commentData.comment);
  });

  it("should render a h6 comment-thread__title with author name", () => {
    const wrapper = shallow(<CommentThread comment={comment} />);
    expect(wrapper.find('h6.comment-thread__title')).to.have.text(`Conversation with ${comment.author.name}`);
  });
});
