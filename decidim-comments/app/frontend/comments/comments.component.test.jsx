import { shallow }   from 'enzyme';
import graphql       from 'graphql-anywhere';
import gql           from 'graphql-tag';

import { Comments }  from './comments.component';
import CommentThread from './comment_thread.component';

describe('<Comments />', () => {
  let comments = [];

  beforeEach(() => {
    const commentsData = {
      comments: [
        {
          id: "1"
        },
        {
          id: "2"
        }
      ]
    };

    const query = gql`
      query GetComments {
        comments {
          id,
          ...CommentThread
        }
      }
      ${CommentThread.fragments.comment}
    `;

    const resolver = (fieldName, root) => root[fieldName];

    let result = graphql(
      resolver,
      query,
      commentsData
    );
    
    comments = result.comments;
  });

  it("renders a div of id comments", () => {
    const wrapper = shallow(<Comments comments={comments} />);
    expect(wrapper.find('#comments')).to.be.present();
  })
});
