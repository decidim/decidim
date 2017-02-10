import { Component, PropTypes } from 'react';
import { graphql }              from 'react-apollo';
import gql                      from 'graphql-tag';
import { filter }               from 'graphql-anywhere';
import { I18n }                 from 'react-i18nify';

import Application              from '../application/application.component';

import CommentThread            from './comment_thread.component';
import AddCommentForm           from './add_comment_form.component';
import CommentOrderSelector     from './comment_order_selector.component';

import commentsQuery            from './comments.query.graphql';

/**
 * The core class of the Decidim Comments engine.
 * It renders a collection of comments given a commentable id and type.
 * @global
 * @class
 * @augments Component
 */
export class Comments extends Component {
  render() {
    const { commentable: { comments }, reorderComments, orderBy, loading } = this.props;
    let commentClasses = "comments";
    let commentHeader = I18n.t("components.comments.title", { count: comments.length });

    if (loading) {
      commentClasses += " loading-comments"
      commentHeader = I18n.t("components.comments.loading");
    }

    return (
      <div className="columns large-9" id="comments">
        <section className={commentClasses}>
          <div className="row collapse order-by">
            <h2 className="order-by__text section-heading">
              { commentHeader }
            </h2>
            <CommentOrderSelector
              reorderComments={reorderComments}
              defaultOrderBy={orderBy}
            />
          </div>
          {this._renderCommentThreads()}
          {this._renderAddCommentForm()}
        </section>
      </div>
    );
  }

  /**
   * Iterates the comment's collection and render a CommentThread for each one
   * @private
   * @returns {ReactComponent[]} - A collection of CommentThread components
   */
  _renderCommentThreads() {
    const { session, commentable: { comments, commentsHaveVotes } } = this.props;

    return comments.map((comment) => (
      <CommentThread
        key={comment.id}
        comment={filter(CommentThread.fragments.comment, comment)}
        session={session}
        votable={commentsHaveVotes}
      />
    ))
  }

  /**
   * If current user is present it renders the add comment form
   * @private
   * @returns {Void|ReactComponent} - A AddCommentForm component or nothing
   */
  _renderAddCommentForm() {
    const { session, commentable: { canHaveComments, commentsHaveAlignment } } = this.props;

    if (session && canHaveComments) {
      return (
        <AddCommentForm
          session={session}
          arguable={commentsHaveAlignment}
        />
      );
    }

    return null;
  }
}

Comments.propTypes = {
  loading: PropTypes.bool,
  session: PropTypes.shape({
    user: PropTypes.any.isRequired
  }),
  commentable: PropTypes.shape({
    canHaveComments: PropTypes.bool,
    commentsHaveAlignment: PropTypes.bool,
    commentsHaveVotes: PropTypes.bool,
    comments: PropTypes.arrayOf(PropTypes.shape({
      id: PropTypes.string.isRequired
    }))
  }),
  orderBy: PropTypes.string.isRequired,
  reorderComments: PropTypes.func.isRequired
};

Comments.defaultProps = {
  loading: false,
  session: null,
  commentable: {
    comments: []
  }
};

/**
 * Wrap the Comments component with a GraphQL query and children
 * fragments.
 */

window.Comments = Comments;

const CommentsWithData = graphql(gql`
  ${commentsQuery}
  ${AddCommentForm.fragments.user}
  ${CommentThread.fragments.comment}
`, {
  options: {
    pollInterval: 15000
  },
  props: ({ ownProps, data: { loading, session, commentable, refetch }}) => ({
    loading,
    session,
    commentable,
    orderBy: ownProps.orderBy,
    reorderComments: (orderBy) => {
      return refetch({
        orderBy
      });
    }
  })
})(Comments);

/**
 * Wrap the CommentsWithData component within an Application component to
 * connect it with Apollo client and store.
 * @returns {ReactComponent} - A component wrapped within an Application component
 */
const CommentsApplication = ({ locale, commentableId, commentableType }) => (
  <Application locale={locale}>
    <CommentsWithData
      commentableId={commentableId}
      commentableType={commentableType}
      orderBy="older"
    />
  </Application>
);

CommentsApplication.propTypes = {
  locale: PropTypes.string.isRequired,
  commentableId: React.PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.number
  ]).isRequired,
  commentableType: PropTypes.string.isRequired
};

export default CommentsApplication;
