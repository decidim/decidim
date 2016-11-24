import { Component, PropTypes } from 'react';
import { graphql, compose }     from 'react-apollo';
import gql                      from 'graphql-tag';

import ApolloApplication        from '../application/apollo_application.component';

import FeaturedComment          from './featured_comment.component';
import CommentOrderSelector     from './comment_order_selector.component';
import CommentThread            from './comment_thread.component';
import AddCommentForm           from './add_comment_form.component';

export class Comments extends Component {
  render() {
    const { data: { processes } } = this.props;

    return (
      <div className="columns large-9" id="comments">
        <FeaturedComment />
        <section className="comments">
          <div className="row collapse order-by">
            <h2 className="order-by__text section-heading">132 comentaris -
              <span className="order-by__tabs">
                <a className="order-by__tab">a favor</a>
                <a className="order-by__tab">en contra</a>
              </span>
            </h2>
            <CommentOrderSelector />
          </div>
          <CommentThread />
          <div className="show-more show-more--comment-thread">
            <button className="muted-link">
              Ver 16 comentarios más
              <span aria-hidden="true">+</span>
            </button>
          </div>
          <AddCommentForm />
        </section>
      </div>
    );
  }
}

Comments.propTypes = {
  data: PropTypes.shape({
    comments: PropTypes.object
  })
};

const CommentsWithData = compose(
  graphql(gql`
    query {
      processes {
        id
      }
    }
  `)
)(Comments);

const CommentsApplication = () => (
  <ApolloApplication>
    <CommentsWithData />
  </ApolloApplication>
);

export default CommentsApplication;
