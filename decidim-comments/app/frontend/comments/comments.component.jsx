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
    const { comments, reorderComments, orderBy, loading } = this.props;
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
    const { comments, session, options: { votable } } = this.props;

    return comments.map((comment) => (
      <CommentThread
        key={comment.id}
        comment={filter(CommentThread.fragments.comment, comment)}
        session={session}
        votable={votable}
      />
    ))
  }

  /**
   * If current user is present it renders the add comment form
   * @private
   * @returns {Void|ReactComponent} - A AddCommentForm component or nothing
   */
  _renderAddCommentForm() {
    const { session, commentableId, commentableType, options: { arguable } } = this.props;

    if (session) {
      return (
        <AddCommentForm
          session={session}
          commentableId={commentableId}
          commentableType={commentableType}
          arguable={arguable}
        />
      );
    }

    return null;
  }
}

Comments.propTypes = {
  loading: PropTypes.bool,
  comments: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.string.isRequired
  })),
  session: PropTypes.shape({
    user: PropTypes.any.isRequired
  }),
  commentableId: PropTypes.string.isRequired,
  commentableType: PropTypes.string.isRequired,
  options: PropTypes.shape({
    arguable: PropTypes.bool
  }).isRequired,
  orderBy: PropTypes.string.isRequired,
  reorderComments: PropTypes.func.isRequired
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
  props: ({ ownProps, data: { loading, session, comments, refetch }}) => ({
    loading: loading,
    comments: comments || [],
    session,
    commentableId: ownProps.commentableId,
    commentableType: ownProps.commentableType,
    orderBy: ownProps.orderBy,
    options: ownProps.options,
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
const CommentsApplication = ({ locale, commentableId, commentableType, options }) => (
  <Application locale={locale}>
    <CommentsWithData
      commentableId={commentableId}
      commentableType={commentableType}
      options={options}
      orderBy="older"
    />
  </Application>
);

CommentsApplication.propTypes = {
  locale: PropTypes.string.isRequired,
  commentableId: React.PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.number
  ]),
  commentableType: PropTypes.string.isRequired,
  options: PropTypes.shape({
    arguable: PropTypes.bool
  }).isRequired
};

export default CommentsApplication;
