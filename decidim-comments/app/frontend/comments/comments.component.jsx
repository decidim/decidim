import { Component, PropTypes } from 'react';
import { graphql, compose }     from 'react-apollo';
import gql                      from 'graphql-tag';
import { filter }               from 'graphql-anywhere';
import { I18n }                 from 'react-i18nify';

import Application              from '../application/application.component';

import CommentThread            from './comment_thread.component';
import AddCommentForm           from './add_comment_form.component';

import commentsQuery            from './comments.query.graphql';

export class Comments extends Component {
  render() {
    const { comments } = this.props;

    return (
      <div className="columns large-9" id="comments">
        <section className="comments">
          <div className="row collapse order-by">
            <h2 className="order-by__text section-heading">
              { I18n.t("comments.title", { count: comments.length }) }
            </h2>
          </div>
          {this._renderCommentThreads()}
          {this._renderAddCommentForm()}
        </section>
      </div>
    );
  }

  _renderCommentThreads() {
    const { comments } = this.props;

    return comments.map((comment) => (
      <CommentThread 
        key={comment.id} 
        comment={filter(CommentThread.fragments.comment, comment)} 
      />
    ))
  }

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

const CommentsWithData = compose(
  graphql(gql`
    ${commentsQuery}
    ${CommentThread.fragments.comment}
  `, {
    props: ({ ownProps, data: { comments }}) => ({
      comments: comments || [],
      session: ownProps.session,
      commentableId: ownProps.commentableId,
      commentableType: ownProps.commentableType
    })
  })
)(Comments);

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
