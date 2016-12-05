import { Component }         from 'react';
import { filter, propType }  from 'graphql-anywhere';
import gql                   from 'graphql-tag';
import { I18n }              from 'react-i18nify';

import Comment               from './comment.component';

import commentThreadFragment from './comment_thread.fragment.graphql'

class CommentThread extends Component {
  render() {
    const { comment } = this.props;
    const { author } = comment;

    return (
      <div>
        <h6 className="comment-thread__title">
          { I18n.t("components.comment_thread.title", { authorName: author.name }) }
        </h6>
        <div className="comment-thread">
          <Comment comment={filter(Comment.fragments.comment, comment)} />
        </div>
      </div>
    );
  }
}

CommentThread.fragments = {
  comment: gql`
    ${commentThreadFragment}
    ${Comment.fragments.comment}
  `
};

CommentThread.propTypes = {
  comment: propType(CommentThread.fragments.comment).isRequired
};

export default CommentThread;
