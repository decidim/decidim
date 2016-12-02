import { Component, PropTypes } from 'react';
import { graphql, compose }     from 'react-apollo';
import gql                      from 'graphql-tag';
import { filter }               from 'graphql-anywhere';
import { I18n, Translate }      from 'react-i18nify';

import ApolloApplication        from '../application/apollo_application.component';

import CommentThread            from './comment_thread.component';
import AddCommentForm           from './add_comment_form.component';

import commentsQuery            from './comments.query.graphql'

I18n.setTranslations({
  en: {
    hello: 'World'
  },
  es: {
    hello: 'Mundo'
  },
  ca: {
    hello: 'Món'
  }
});

export class Comments extends Component {
  componentWillReceiveProps(nextProps) {
    const { session } = nextProps;
    if (session) {
      I18n.setLocale(session.locale);
    }
  }

  render() {
    const { comments } = this.props;

    return (
      <div className="columns large-9" id="comments">
        <Translate value="hello" />
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
    currentUser: PropTypes.object,
    locale: PropTypes.string.isRequired
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
  <ApolloApplication>
    <CommentsWithData 
      session={session}
      commentableId={commentableId}
      commentableType={commentableType}
    />
  </ApolloApplication>
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
