import { shallow }          from 'enzyme';
import gql                  from 'graphql-tag';

import { Comments }         from './comments.component';
import CommentThread        from './comment_thread.component';
import AddCommentForm       from './add_comment_form.component';

import commentsQuery        from './comments.query.graphql'

import stubComponent        from '../support/stub_component';
import generateCommentsData from '../support/generate_comments_data';
import resolveGraphQLQuery  from '../support/resolve_graphql_query';

describe('<Comments />', () => {
  let comments = [];

  stubComponent(CommentThread);
  stubComponent(AddCommentForm);

  beforeEach(() => {
    const commentsData = generateCommentsData(15);

    const query = gql`
      ${commentsQuery}
      fragment CommentThread on Comment {
        body
      }
    `;

    comments = resolveGraphQLQuery(query, commentsData).comments;
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
