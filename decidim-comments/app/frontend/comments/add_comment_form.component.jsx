/* eslint-disable no-return-assign, react/no-unused-prop-types */
import { Component, PropTypes } from 'react';
import { graphql }              from 'react-apollo';
import gql                      from 'graphql-tag';
import { I18n }                 from 'react-i18nify';
import uuid                     from 'uuid';
import moment                   from 'moment';
import classnames               from 'classnames';

import addCommentMutation       from './add_comment_form.mutation.graphql';
import commentDataFragment      from './comment_data.fragment.graphql';

/**
 * Renders a form to create new comments.
 * @class
 * @augments Component
 */
export class AddCommentForm extends Component {
  constructor(props) {
    super(props);

    this.state = {
      disabled: true
    };

    if (props.arguable) {
      this.state = {
        ...this.state,
        alignment: 0
      };
    }
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
    const buttonClassNames = classnames('button', 'small', 'button--muted');
    const okButtonClassNames = classnames(buttonClassNames, 'opinion-toggle--ok', {
      'is-active': alignment === 1
    });
    const koButtonClassNames = classnames(buttonClassNames, 'opinion-toggle--ko', {
      'is-active': alignment === -1
    });

    if (arguable) {
      return (
        <div className="opinion-toggle button-group">
          <button 
            className={okButtonClassNames}
            onClick={() => this.setState({ alignment: 1 })}
          >
            Estic a favor
          </button>
          <button
            className={koButtonClassNames}
            onClick={() => this.setState({ alignment: -1 })}
          >
            Estic en contra
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
    const { addComment, onCommentAdded } = this.props;

    evt.preventDefault();

    addComment({ body: this.bodyTextArea.value });
    this.bodyTextArea.value = '';

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
  ${commentDataFragment}
`, {
  props: ({ ownProps, mutate }) => ({
    addComment: ({ body }) => mutate({ 
      variables: { 
        commentableId: ownProps.commentableId,
        commentableType: ownProps.commentableType,
        body
      },
      optimisticResponse: {
        __typename: 'Mutation',
        addComment: {
          __typename: 'Comment',
          id: uuid(),
          createdAt: moment().format("YYYY-MM-DD HH:mm:ss z"),
          body,
          author: {
            __typename: 'Author',
            name: ownProps.currentUser.name,
            avatarUrl: ownProps.currentUser.avatarUrl
          },
          replies: [],
          canHaveReplies: false
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
