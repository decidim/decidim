import { Component, PropTypes } from 'react';
import { graphql }              from 'react-apollo';
import gql                      from 'graphql-tag';
import { filter }               from 'graphql-anywhere';
import { I18n }                 from 'react-i18nify';

import Application              from '../application/application.component';

import CommentThread            from './comment_thread.component';
import AddCommentForm           from './add_comment_form.component';

import commentsQuery            from './comments.query.graphql';

/**
 * The core class of the Decidim Comments engine.
 * It renders a collection of comments given a commentable id and type.
 * @global
 */
export class Comments extends Component {
  render() {
    const { comments } = this.props;

    return (
      <div className="columns large-9" id="comments">
        <section className="comments">
          <div className="row collapse order-by">
            <h2 className="order-by__text section-heading">
              { I18n.t("components.comments.title", { count: comments.length }) }
            </h2>
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
    const { comments } = this.props;

    return comments.map((comment) => (
      <CommentThread 
        key={comment.id} 
        comment={filter(CommentThread.fragments.comment, comment)} 
      />
    ))
  }
 
  /**
   * If session's current user is present it renders the add comment form
   * @private
   * @returns {Void|ReactComponent} - A AddCommentForm component or nothing
   */
  _renderAddCommentForm() {
    const { session, commentableId, commentableType } = this.props;
    
    if (session.currentUser) {
      return (
        <AddCommentForm 
          session={session}
          commentableId={commentableId}
          commentableType={commentableType}
        />
      );
    }

    return null;
  }
}

Comments.propTypes = {
  comments: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.string.isRequired
  })),
  session: PropTypes.shape({
    currentUser: PropTypes.object
  }).isRequired,
  commentableId: PropTypes.string.isRequired,
  commentableType: PropTypes.string.isRequired
};

/**
 * Wrap the Comments component with a GraphQL query and children
 * fragments.
 */
const CommentsWithData = graphql(gql`
  ${commentsQuery}
  ${CommentThread.fragments.comment}
`, {
  props: ({ ownProps, data: { comments }}) => ({
    comments: comments || [],
    session: ownProps.session,
    commentableId: ownProps.commentableId,
    commentableType: ownProps.commentableType
  })
})(Comments);

/**
 * Wrap the CommentsWithData component within an Application component to
 * connect it with Apollo client and store.
 * @returns {ReactComponent} - A component wrapped within an Application component
 */
const CommentsApplication = ({ session, commentableId, commentableType }) => (
  <Application session={session}>
    <CommentsWithData 
      session={session}
      commentableId={commentableId}
      commentableType={commentableType}
    />
  </Application>
);

CommentsApplication.propTypes = {
  session: PropTypes.shape({
    currentUser: PropTypes.object,
    locale: PropTypes.string.isRequired
  }).isRequired,
  commentableId: React.PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.number
  ]),
  commentableType: PropTypes.string.isRequired
};

export default CommentsApplication;
