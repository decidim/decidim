import { Component }                        from 'react';
import { ApolloProvider, graphql, compose } from 'react-apollo';
import gql                                  from 'graphql-tag';

import apolloClient                         from '../application/apollo_client';

import FeaturedComment                      from './featured_comment.component';
import CommentOrderSelector                 from './comment_order_selector.component';
import CommentThread                        from './comment_thread.component';
import AddCommentForm                       from './add_comment_form.component';

export class Comments extends Component {
  render() {
    // const { data: { processes, loading } } = this.props;
    // console.log(processes);

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

const CommentsWithData = compose(
  graphql(gql`{
    processes {
      id,
      title {
        translation(locale: "ca")
      }
    }
  }`)
)(Comments);

export default class CommentsApplication extends Component {
  render() {
    return (
      <ApolloProvider client={apolloClient}>
        <CommentsWithData />
      </ApolloProvider>
    );
  }
}
