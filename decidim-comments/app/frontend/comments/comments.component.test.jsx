import { shallow }   from 'enzyme';
import graphql       from 'graphql-anywhere';
import gql           from 'graphql-tag';

import { Comments }  from './comments.component';

import commentsQuery from './comments.query.graphql'

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
      ${commentsQuery}
      fragment CommentThread on Comment {
        body
      }
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
