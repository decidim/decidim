import { shallow }          from 'enzyme';
import { filter }           from 'graphql-anywhere';
import gql                  from 'graphql-tag';

import { Comments }         from './comments.component';
import CommentThread        from './comment_thread.component';
import AddCommentForm       from './add_comment_form.component';
import CommentOrderSelector from './comment_order_selector.component';

import commentsQuery        from './comments.query.graphql'

import stubComponent        from '../support/stub_component';
import generateCommentsData from '../support/generate_comments_data';
import generateUserData     from '../support/generate_user_data';
import resolveGraphQLQuery  from '../support/resolve_graphql_query';

describe('<Comments />', () => {
  let comments = [];
  let session = null;
  const commentableId = "1";
  const commentableType = "Decidim::ParticipatoryProcess";
  const orderBy = "older";
  const reorderComments = () => {};

  const commentThreadFragment = gql`
    fragment CommentThread on Comment {
      author
    }
  `;

  const addCommentFragment = gql`
    fragment AddCommentForm on User {
      verifiedUserGroups {
        id
      }
    }
  `;

  stubComponent(CommentOrderSelector)

  stubComponent(CommentThread, {
    fragments: {
      comment: commentThreadFragment
    }
  });

  stubComponent(AddCommentForm, {
    fragments: {
      user: addCommentFragment
    }
  });

  beforeEach(() => {
    const userData = generateUserData();
    const commentsData = generateCommentsData(15);

    const query = gql`
      ${commentsQuery}
      ${commentThreadFragment}
      ${addCommentFragment}
    `;

    const result = resolveGraphQLQuery(query, {
      filterResult: false,
      rootValue: {
        session: {
          user: userData
        },
        comments: commentsData
      },
      variables: {
        orderBy,
        commentableId,
        commentableType
      }
    });

    session = result.session;
    comments = result.comments;
  });

  it("should render loading-comments calss and the respective loading text", () => {
    const wrapper = shallow(<Comments comments={comments} commentableId={commentableId} commentableType={commentableType} currentUser={currentUser} options={{}} reorderComments={reorderComments} orderBy={orderBy} loading />);
    expect(wrapper.find('.loading-comments')).to.be.present();
    expect(wrapper.find('h2')).to.have.text("Loading comments ...");
  });

  it("should render a div of id comments", () => {
    const wrapper = shallow(<Comments comments={comments} commentableId={commentableId} commentableType={commentableType} session={session} options={{}} reorderComments={reorderComments} orderBy={orderBy} />);
    expect(wrapper.find('#comments')).to.be.present();
  });

  describe("should render a CommentThread component for each comment", () => {
    it("and pass filter comment data as a prop to it", () => {
      const wrapper = shallow(<Comments comments={comments} commentableId={commentableId} commentableType={commentableType} session={session} options={{}} reorderComments={reorderComments} orderBy={orderBy} />);
      expect(wrapper).to.have.exactly(comments.length).descendants(CommentThread);
      wrapper.find(CommentThread).forEach((node, idx) => {
        expect(node).to.have.prop("comment").deep.equal(filter(commentThreadFragment, comments[idx]));
      });
    });

    it("and pass the session as a prop to it", () => {
      const wrapper = shallow(<Comments comments={comments} commentableId={commentableId} commentableType={commentableType} session={session} options={{}} reorderComments={reorderComments} orderBy={orderBy} />);
      expect(wrapper).to.have.exactly(comments.length).descendants(CommentThread);
      wrapper.find(CommentThread).forEach((node) => {
        expect(node).to.have.prop("session").deep.equal(session);
      });
    });

    it("and pass the option votable as a prop to it", () => {
      const wrapper = shallow(<Comments comments={comments} commentableId={commentableId} commentableType={commentableType} session={session} options={{ votable: true }} reorderComments={reorderComments} orderBy={orderBy} />);
      expect(wrapper).to.have.exactly(comments.length).descendants(CommentThread);
      wrapper.find(CommentThread).forEach((node) => {
        expect(node).to.have.prop("votable").equal(true);
      });
    });
  });

  it("should render comments count", () => {
    const wrapper = shallow(<Comments comments={comments} commentableId={commentableId} commentableType={commentableType} session={session} options={{}} reorderComments={reorderComments} orderBy={orderBy} />);
    const rex = new RegExp(`${comments.length} comments`);
    expect(wrapper.find('h2.section-heading')).to.have.text().match(rex);
  });

  it("should render a AddCommentForm component and pass 'options.arguable' as a prop", () => {
    const wrapper = shallow(<Comments comments={comments} commentableId={commentableId} commentableType={commentableType} session={session} options={{ arguable: true }} reorderComments={reorderComments} orderBy={orderBy} />);
    expect(wrapper).to.have.exactly(1).descendants(AddCommentForm);
    expect(wrapper.find(AddCommentForm)).to.have.prop('arguable').equal(true);
  });

  describe("if session is not present", () => {
    beforeEach(() => {
      session = null;
    });

    it("should not render a AddCommentForm component", () => {
      const wrapper = shallow(<Comments comments={comments} commentableId={commentableId} commentableType={commentableType} session={session} options={{}} reorderComments={reorderComments} orderBy={orderBy} />);
      expect(wrapper.find(AddCommentForm)).not.to.be.present();
    });
  });

  describe("should render a CommentOrderSelector component", () => {
    it("should render a CommentOrderSelector component", () => {
        const wrapper = shallow(<Comments comments={comments} commentableId={commentableId} commentableType={commentableType} session={session} options={{}} reorderComments={reorderComments} orderBy={orderBy} />);
        expect(wrapper.find(CommentOrderSelector)).to.be.present();
      });

    it("and pass the reorderComments as a prop to it", () => {
      const wrapper = shallow(<Comments comments={comments} commentableId={commentableId} commentableType={commentableType} session={session} options={{}} reorderComments={reorderComments} orderBy={orderBy} />);
      expect(wrapper.find(CommentOrderSelector)).to.have.prop('reorderComments').deep.equal(reorderComments);
    });

    it("and pass the orderBy as a prop to it", () => {
      const wrapper = shallow(<Comments comments={comments} commentableId={commentableId} commentableType={commentableType} session={session} options={{}} reorderComments={reorderComments} orderBy={orderBy} />);
      expect(wrapper.find(CommentOrderSelector)).to.have.prop('defaultOrderBy').equal('older');
    });
  });
});
