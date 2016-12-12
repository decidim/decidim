import { shallow }             from 'enzyme';
import { filter }              from 'graphql-anywhere';
import gql                     from 'graphql-tag';

import { Comments }            from './comments.component';
import CommentThread           from './comment_thread.component';
import AddCommentForm          from './add_comment_form.component';

import commentsQuery           from './comments.query.graphql'

import stubComponent           from '../support/stub_component';
import generateCommentsData    from '../support/generate_comments_data';
import generateCurrentUserData from '../support/generate_current_user_data';
import resolveGraphQLQuery     from '../support/resolve_graphql_query';

describe('<Comments />', () => {
  let comments = [];
  let currentUser = null;
  const commentableId = "1";
  const commentableType = "Decidim::ParticipatoryProcess";

  const commentThreadFragment = gql`
    fragment CommentThread on Comment {
      author
    }
  `;

  stubComponent(CommentThread, {
    fragments: {
      comment: commentThreadFragment
    }
  });
  
  stubComponent(AddCommentForm);

  beforeEach(() => {
    const currentUserData = generateCurrentUserData();
    const commentsData = generateCommentsData(15);

    const query = gql`
      ${commentsQuery}
      ${commentThreadFragment}
    `;

    const result = resolveGraphQLQuery(query, {
      filterResult: false,
      rootValue: {
        currentUser: currentUserData,
        comments: commentsData
      },
      variables: {
        commentableId,
        commentableType
      }
    });

    currentUser = result.currentUser;
    comments = result.comments;
  });

  it("should render a div of id comments", () => {
    const wrapper = shallow(<Comments comments={comments} commentableId={commentableId} commentableType={commentableType} currentUser={currentUser} />);
    expect(wrapper.find('#comments')).to.be.present();
  });

  describe("should render a CommentThread component for each comment", () => {
    it("and pass filter comment data as a prop to it", () => {
      const wrapper = shallow(<Comments comments={comments} commentableId={commentableId} commentableType={commentableType} currentUser={currentUser} />);
      expect(wrapper).to.have.exactly(comments.length).descendants(CommentThread);
      wrapper.find(CommentThread).forEach((node, idx) => {
        expect(node).to.have.prop("comment").deep.equal(filter(commentThreadFragment, comments[idx]));
      });
    });

    it("and pass the currentUser as a prop to it", () => {
      const wrapper = shallow(<Comments comments={comments} commentableId={commentableId} commentableType={commentableType} currentUser={currentUser} />);
      expect(wrapper).to.have.exactly(comments.length).descendants(CommentThread);
      wrapper.find(CommentThread).forEach((node) => {
        expect(node).to.have.prop("currentUser").deep.equal(currentUser);
      });
    });
  });

  it("should render comments count", () => {
    const wrapper = shallow(<Comments comments={comments} commentableId={commentableId} commentableType={commentableType} currentUser={currentUser} />);
    const rex = new RegExp(`${comments.length} comments`);
    expect(wrapper.find('h2.section-heading')).to.have.text().match(rex);
  });

  it("should render a AddCommentForm component", () => {
    const wrapper = shallow(<Comments comments={comments} commentableId={commentableId} commentableType={commentableType} currentUser={currentUser} />);
    expect(wrapper).to.have.exactly(1).descendants(AddCommentForm);
  });

  describe("if currentUser is not present", () => {
    beforeEach(() => {
      currentUser = null;
    });

    it("should not render a AddCommentForm component", () => {
      const wrapper = shallow(<Comments comments={comments} commentableId={commentableId} commentableType={commentableType} currentUser={currentUser} />);
      expect(wrapper.find(AddCommentForm)).not.to.be.present();
    });
  });
});
