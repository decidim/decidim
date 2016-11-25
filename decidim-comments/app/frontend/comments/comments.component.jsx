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
          <AddCommentForm />
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
}

Comments.propTypes = {
  comments: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.string.isRequired,
    body: PropTypes.string.isRequired
  }))
};

const CommentsWithData = compose(
  graphql(gql`
    ${commentsQuery}
    ${CommentThread.fragments.comment}
  `, {
    props: ({ data: { comments }}) => ({
      comments: comments || []
    })
  })
)(Comments);

const CommentsApplication = () => (
  <ApolloApplication>
    <CommentsWithData />
  </ApolloApplication>
);

export default CommentsApplication;
