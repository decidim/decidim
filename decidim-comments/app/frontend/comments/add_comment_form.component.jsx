/* eslint-disable no-return-assign, react/no-unused-prop-types */
import { Component, PropTypes } from 'react';
import { graphql }              from 'react-apollo';
import gql                      from 'graphql-tag';
import { I18n }                 from 'react-i18nify';
import uuid                     from 'uuid';
import classnames               from 'classnames';

import Icon                     from '../application/icon.component';

import addCommentMutation       from './add_comment_form.mutation.graphql';
import commentThreadFragment    from './comment_thread.fragment.graphql'
import commentFragment          from './comment.fragment.graphql';
import commentDataFragment      from './comment_data.fragment.graphql';
import upVoteFragment           from './up_vote.fragment.graphql';
import downVoteFragment         from './down_vote.fragment.graphql';

/**
 * Renders a form to create new comments.
 * @class
 * @augments Component
 */
export class AddCommentForm extends Component {
  constructor(props) {
    super(props);

    this.state = {
      disabled: true,
      alignment: 0
    };
  }

  render() {
    const { submitButtonClassName, commentableType, commentableId } = this.props;
    const { disabled } = this.state;
    
    return (
      <div className="add-comment">
        {this._renderHeading()}
        {this._renderOpinionButtons()}
        <form onSubmit={(evt) => this._addComment(evt)}>
          <label className="show-for-sr" htmlFor={`add-comment-${commentableType}-${commentableId}`}>{ I18n.t("components.add_comment_form.form.body.label") }</label>
          <textarea
            ref={(textarea) => this.bodyTextArea = textarea}
            id={`add-comment-${commentableType}-${commentableId}`}
            rows="4"
            placeholder={I18n.t("components.add_comment_form.form.body.placeholder")}
            onChange={(evt) => this._checkCommentBody(evt.target.value)}
          />
          <input 
            type="submit"
            className={submitButtonClassName}
            value={I18n.t("components.add_comment_form.form.submit")}
            disabled={disabled}
          />
        </form>
      </div>
    );
  }

  /**
   * Render the form heading based on showTitle prop
   * @private
   * @returns {Void|DOMElement} - The heading or an empty element
   */
  _renderHeading() {
    const { showTitle } = this.props;

    if (showTitle) {
      return (
        <h5 className="section-heading">
          { I18n.t("components.add_comment_form.title") }
        </h5>
      );
    }

    return null;
  }

  /**
   * Render opinion buttons or not based on the arguable prop
   * @private
   * @returns {Void|DOMElement} - Returns nothing or a wrapper with buttons
   */
  _renderOpinionButtons() {
    const { arguable } = this.props;
    const { alignment } = this.state;
    const buttonClassName = classnames('button', 'small', 'button--muted');
    const okButtonClassName = classnames(buttonClassName, 'opinion-toggle--ok', {
      'is-active': alignment === 1
    });
    const koButtonClassName = classnames(buttonClassName, 'opinion-toggle--ko', {
      'is-active': alignment === -1
    });
    const neutralButtonClassName = classnames(buttonClassName, 'opinion-toggle--neutral', {
      'is-active': alignment === 0
    });

    if (arguable) {
      return (
        <div className="opinion-toggle button-group">
          <button 
            className={okButtonClassName}
            onClick={() => this.setState({ alignment: 1 })}
          >
            <Icon name="icon-thumb-up" />
            { I18n.t("components.add_comment_form.opinion.in_favor") }
          </button>
          <button
            className={neutralButtonClassName}
            onClick={() => this.setState({ alignment: 0 })}
          >
            { I18n.t("components.add_comment_form.opinion.neutral") }
          </button>
          <button
            className={koButtonClassName}
            onClick={() => this.setState({ alignment: -1 })}
          >
            <Icon name="icon-thumb-down" />
            { I18n.t("components.add_comment_form.opinion.against") }
          </button>
        </div>
      );
    }

    return null;
  }
 
  /**
   * Check comment's body and disable form if it's empty
   * @private
   * @param {string} body - The comment's body
   * @returns {Void} - Returns nothing
   */
  _checkCommentBody(body) {
    this.setState({ disabled: body === '' });
  }

  /**
   * Handle form's submission and calls `addComment` prop with the value of the
   * form's textarea. It prevents the default form submission event.
   * @private
   * @param {DOMEvent} evt - The form's submission event
   * @returns {Void} - Returns nothing
   */
  _addComment(evt) {
    const { alignment } = this.state;
    const { addComment, onCommentAdded } = this.props;

    evt.preventDefault();

    addComment({ body: this.bodyTextArea.value, alignment });

    this.bodyTextArea.value = '';
    this.setState({ alignment: 0 });

    if (onCommentAdded) {
      onCommentAdded();
    }
  }
}

AddCommentForm.defaultProps = {
  showTitle: true,
  submitButtonClassName: 'button button--sc'
};

AddCommentForm.propTypes = {
  addComment: PropTypes.func.isRequired,
  currentUser: PropTypes.shape({
    name: PropTypes.string.isRequired
  }).isRequired,
  commentableId: PropTypes.string.isRequired,
  commentableType: PropTypes.string.isRequired,
  showTitle: PropTypes.bool.isRequired,
  submitButtonClassName: PropTypes.string.isRequired,
  onCommentAdded: PropTypes.func,
  arguable: PropTypes.bool
};

const AddCommentFormWithMutation = graphql(gql`
  ${addCommentMutation}
  ${commentThreadFragment}
  ${commentFragment}
  ${commentDataFragment}
  ${upVoteFragment}
  ${downVoteFragment}
`, {
  props: ({ ownProps, mutate }) => ({
    addComment: ({ body, alignment }) => mutate({ 
      variables: { 
        commentableId: ownProps.commentableId,
        commentableType: ownProps.commentableType,
        body,
        alignment
      },
      optimisticResponse: {
        __typename: 'Mutation',
        addComment: {
          __typename: 'Comment',
          id: uuid(),
          createdAt: new Date().toISOString(),
          body,
          alignment: alignment,
          author: {
            __typename: 'Author',
            name: ownProps.currentUser.name,
            avatarUrl: ownProps.currentUser.avatarUrl
          },
          replies: [],
          hasReplies: false,
          canHaveReplies: false,
          upVotes: 0,
          upVoted: false,
          downVotes: 0,
          downVoted: false
        }
      },
      updateQueries: {
        GetComments: (prev, { mutationResult: { data } }) => {
          const { commentableId, commentableType } = ownProps;
          const newComment = data.addComment;
          let comments = [];

          const commentReducer = (comment) => {
            const replies = comment.replies || [];

            if (comment.id === commentableId) {
              return {
                ...comment,
                replies: [
                  ...replies,
                  newComment
                ]
              };
            }
            return {
              ...comment,
              replies: replies.map(commentReducer)
            };
          };

          if (commentableType === "Decidim::Comments::Comment") {
            comments = prev.comments.map(commentReducer);
          } else {
            comments = [
              ...prev.comments,
              newComment
            ];
          }

          return {
            ...prev,
            comments
          };
        }
      }
    })
  })
})(AddCommentForm);

export default AddCommentFormWithMutation;
