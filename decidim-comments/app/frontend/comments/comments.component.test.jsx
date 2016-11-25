import { shallow }         from 'enzyme';
import graphql, { filter } from 'graphql-anywhere';
import gql                 from 'graphql-tag';
import { random }          from 'faker/locale/en';

import { Comments }        from './comments.component';
import CommentThread       from './comment_thread.component';
import AddCommentForm      from './add_comment_form.component';

import commentsQuery       from './comments.query.graphql'

describe('<Comments />', () => {
  let comments = [];

  const generateCommentsData = (num = 1) => {
    let commentsData = {
      comments: []
    };

    for (let idx = 0; idx < num; idx += 1) {
      commentsData.comments.push({
        id: random.uuid(),
        body: random.words()
      })
    }

    return commentsData;
  };
  
  beforeEach(() => {
    const commentsData = generateCommentsData(15);

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

    comments = filter(query, result).comments;
  });

  it("should render a div of id comments", () => {
    const wrapper = shallow(<Comments comments={comments} />);
    expect(wrapper.find('#comments')).to.be.present();
  });

  it("should render a CommentThread component for each comment", () => {
    const wrapper = shallow(<Comments comments={comments} />);
    expect(wrapper).to.have.exactly(comments.length).descendants(CommentThread)
  });

  it("should render a AddCommentForm component", () => {
    const wrapper = shallow(<Comments comments={comments} />);
    expect(wrapper).to.have.exactly(1).descendants(AddCommentForm);
  });

  it("should render comments count", () => {
    const wrapper = shallow(<Comments comments={comments} />);
    const rex = new RegExp(`${comments.length} comments`);
    expect(wrapper.find('h2.section-heading')).to.have.text().match(rex);
  });
});
