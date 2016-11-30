import { Component, PropTypes } from 'react';
import { graphql, compose }     from 'react-apollo';
import gql                      from 'graphql-tag';
import { filter }               from 'graphql-anywhere';

import ApolloApplication        from '../application/apollo_application.component';

import CommentThread            from './comment_thread.component';
import AddCommentForm           from './add_comment_form.component';

import commentsQuery            from './comments.query.graphql'

export class Comments extends Component {
  render() {
    const { comments } = this.props;

    return (
      <div className="columns large-9" id="comments">
        <section className="comments">
          <div className="row collapse order-by">
            <h2 className="order-by__text section-heading">
              { `${comments.length} comments` }
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
    const { session } = this.props;

    if (session && session.currentUser) {
      return <AddCommentForm session={session} />;
    }

    return null;
  }
}

Comments.propTypes = {
  comments: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.string.isRequired
  })),
  session: PropTypes.shape({
    currentUser: PropTypes.object.isRequired
  })
};

const CommentsWithData = compose(
  graphql(gql`
    ${commentsQuery}
    ${CommentThread.fragments.comment}
  `, {
    props: ({ ownProps, data: { comments }}) => ({
      comments: comments || [],
      session: ownProps.session
    })
  })
)(Comments);

const CommentsApplication = ({ session }) => (
  <ApolloApplication>
    <CommentsWithData session={session} />
  </ApolloApplication>
);

CommentsApplication.propTypes = {
  session: PropTypes.shape({
    currentUser: PropTypes.object.isRequired
  })
};

export default CommentsApplication;
