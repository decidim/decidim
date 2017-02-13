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
  let commentable = {};
  let session = null;
  const commentableId = "1";
  const commentableType = "Decidim::DummyResource";
  const orderBy = "older";
  const reorderComments = () => {};

  const commentThreadFragment = gql`
    fragment CommentThread on Comment {
      author
    }
  `;

  const addCommentFragmentSession = gql`
    fragment AddCommentFormSession on Session {
      verifiedUserGroups {
        id
      }
    }
  `;

  const addCommentFragmentCommentable = gql`
    fragment AddCommentFormCommentable on Commentable {
      id
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
      session: addCommentFragmentSession,
      commentable: addCommentFragmentCommentable
    }
  });

  beforeEach(() => {
    const userData = generateUserData();
    const commentsData = generateCommentsData(15);

    const query = gql`
      ${commentsQuery}
      ${commentThreadFragment}
      ${addCommentFragmentSession}
      ${addCommentFragmentCommentable}
    `;

    const result = resolveGraphQLQuery(query, {
      filterResult: false,
      rootValue: {
        session: {
          user: userData
        },
        commentable: {
          acceptsNewComments: true,
          commentsHaveAlignment: true,
          commentsHaveVotes: true,
          comments: commentsData
        }
      },
      variables: {
        orderBy,
        commentableId,
        commentableType
      }
    });

    session = result.session;
    commentable = result.commentable;
  });

  it("renders loading-comments class and the respective loading text", () => {
    const wrapper = shallow(<Comments commentable={commentable} session={session} reorderComments={reorderComments} orderBy={orderBy} loading />);
    expect(wrapper.find('.loading-comments')).to.be.present();
    expect(wrapper.find('h2')).to.have.text("Loading comments ...");
  });

  it("renders a div of id comments", () => {
    const wrapper = shallow(<Comments commentable={commentable} session={session} reorderComments={reorderComments} orderBy={orderBy} />);
    expect(wrapper.find('#comments')).to.be.present();
  });

  describe("renders a CommentThread component for each comment", () => {
    it("and pass filter comment data as a prop to it", () => {
      const wrapper = shallow(<Comments commentable={commentable} session={session} reorderComments={reorderComments} orderBy={orderBy} />);
      expect(wrapper).to.have.exactly(commentable.comments.length).descendants(CommentThread);
      wrapper.find(CommentThread).forEach((node, idx) => {
        expect(node).to.have.prop("comment").deep.equal(filter(commentThreadFragment, commentable.comments[idx]));
      });
    });

    it("and pass the session as a prop to it", () => {
      const wrapper = shallow(<Comments commentable={commentable} session={session} reorderComments={reorderComments} orderBy={orderBy} />);
      expect(wrapper).to.have.exactly(commentable.comments.length).descendants(CommentThread);
      wrapper.find(CommentThread).forEach((node) => {
        expect(node).to.have.prop("session").deep.equal(session);
      });
    });

    it("and pass the commentable 'commentsHaveVotes' property as a prop to it", () => {
      const wrapper = shallow(<Comments commentable={commentable} session={session} reorderComments={reorderComments} orderBy={orderBy} />);
      expect(wrapper).to.have.exactly(commentable.comments.length).descendants(CommentThread);
      wrapper.find(CommentThread).forEach((node) => {
        expect(node).to.have.prop("votable").equal(true);
      });
    });
  });

  it("renders comments count", () => {
    const wrapper = shallow(<Comments commentable={commentable} session={session} reorderComments={reorderComments} orderBy={orderBy} />);
    const rex = new RegExp(`${commentable.comments.length} comments`);
    expect(wrapper.find('h2.section-heading')).to.have.text().match(rex);
  });

  it("renders a AddCommentForm component and pass the commentable 'commentsHaveAlignment' as a prop", () => {
    const wrapper = shallow(<Comments commentable={commentable} session={session} reorderComments={reorderComments} orderBy={orderBy} />);
    expect(wrapper).to.have.exactly(1).descendants(AddCommentForm);
    expect(wrapper.find(AddCommentForm)).to.have.prop('arguable').equal(true);
  });

  describe("when the commentable cannot accept new comments", () => {
    beforeEach(() => {
      commentable.acceptsNewComments = false;
    });

    it("doesn't render an AddCommentForm component", () => {
      const wrapper = shallow(<Comments commentable={commentable} session={session} reorderComments={reorderComments} orderBy={orderBy} />);
      expect(wrapper.find(AddCommentForm)).not.to.be.present();
    });

    it("renders a callout message to inform the user that comments are blocked", () => {
      const wrapper = shallow(<Comments commentable={commentable} session={session} reorderComments={reorderComments} orderBy={orderBy} />);
      expect(wrapper.find('.callout.warning')).to.include.text("disabled");
    });
  });

  describe("renders a CommentOrderSelector component", () => {
    it("and pass the reorderComments as a prop to it", () => {
      const wrapper = shallow(<Comments commentable={commentable} session={session} reorderComments={reorderComments} orderBy={orderBy} />);
      expect(wrapper.find(CommentOrderSelector)).to.have.prop('reorderComments').deep.equal(reorderComments);
    });

    it("and pass the orderBy as a prop to it", () => {
      const wrapper = shallow(<Comments commentable={commentable} session={session} reorderComments={reorderComments} orderBy={orderBy} />);
      expect(wrapper.find(CommentOrderSelector)).to.have.prop('defaultOrderBy').equal('older');
    });
  });
});
