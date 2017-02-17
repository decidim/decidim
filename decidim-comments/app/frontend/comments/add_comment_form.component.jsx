/* eslint-disable no-return-assign, react/no-unused-prop-types, max-lines */
import { Component, PropTypes }          from 'react';
import { graphql }                       from 'react-apollo';
import gql                               from 'graphql-tag';
import { I18n, Translate }               from 'react-i18nify';
import uuid                              from 'uuid';
import classnames                        from 'classnames';

import Icon                              from '../application/icon.component';

import addCommentMutation                from './add_comment_form.mutation.graphql';
import commentThreadFragment             from './comment_thread.fragment.graphql'
import commentFragment                   from './comment.fragment.graphql';
import commentDataFragment               from './comment_data.fragment.graphql';
import upVoteFragment                    from './up_vote.fragment.graphql';
import downVoteFragment                  from './down_vote.fragment.graphql';
import addCommentFormSessionFragment     from './add_comment_form_session.fragment.graphql';
import addCommentFormCommentableFragment from './add_comment_form_commentable.fragment.graphql';

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
      error: false,
      alignment: 0
    };
  }

  render() {
    return (
      <div className="add-comment">
        {this._renderHeading()}
        {this._renderAccountMessage()}
        {this._renderOpinionButtons()}
        {this._renderForm()}
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
   * Render a message telling the user to sign in or sign up to leave a comment.
   * @private
   * @returns {Void|DOMElement} - The message or an empty element.
   */
  _renderAccountMessage() {
    const { session } = this.props;

    if (!session) {
      return (
        <p>
          <Translate
            value="components.add_comment_form.account_message"
            sign_in_url="/users/sign_in"
            sign_up_url="/users/sign_up"
            dangerousHTML
          />
        </p>
      );
    }

    return null;
  }

  /**
   * Render the add comment form if session is present.
   * @private
   * @returns {Void|DOMElement} - The add comment form on an empty element.
   */
  _renderForm() {
    const { session, submitButtonClassName, commentable: { id, type } } = this.props;
    const { disabled } = this.state;

    if (session) {
      return (
        <form onSubmit={(evt) => this._addComment(evt)}>
          {this._renderCommentAs()}
          <div className="field">
            <label className="show-for-sr" htmlFor={`add-comment-${type}-${id}`}>{ I18n.t("components.add_comment_form.form.body.label") }</label>
            {this._renderTextArea()}
            {this._renderTextAreaError()}
            <button
              type="submit"
              className={submitButtonClassName}
              value={I18n.t("components.add_comment_form.form.submit")}
              disabled={disabled}
            />
          </div>
        </form>
      );
    }

    return null;
  }

  /**
   * Render the form heading based on showTitle prop
   * @private
   * @returns {Void|DOMElement} - The heading or an empty element
   */
  _renderTextArea() {
    const { commentable: { id, type }, autoFocus, maxLength } = this.props;
    const { error } = this.state;
    const className = classnames({ 'is-invalid-input': error });

    let textAreaProps = {
      ref: (textarea) => {this.bodyTextArea = textarea},
      id: `add-comment-${type}-${id}`,
      className,
      rows: "4",
      maxLength,
      required: "required",
      pattern: `^(.){0,${maxLength}}$`,
      placeholder: I18n.t("components.add_comment_form.form.body.placeholder"),
      onChange: (evt) => this._checkCommentBody(evt.target.value)
    };
    if (autoFocus) {
      textAreaProps.autoFocus = 'autoFocus';
    }

    return (
      <textarea {...textAreaProps} />
    );
  }

  /**
   * Render the text area form error if state has an error
   * @private
   * @returns {Void|DOMElement} - The error or an empty element
   */
  _renderTextAreaError() {
    const { maxLength } = this.props;
    const { error } = this.state;

    if (error) {
      return (
        <span className="form-error is-visible">
          { I18n.t("components.add_comment_form.form.form_error", { length: maxLength }) }
        </span>
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
    const { session, arguable } = this.props;
    const { alignment } = this.state;
    const buttonClassName = classnames('button', 'tiny', 'button--muted');
    const okButtonClassName = classnames(buttonClassName, 'opinion-toggle--ok', {
      'is-active': alignment === 1
    });
    const koButtonClassName = classnames(buttonClassName, 'opinion-toggle--ko', {
      'is-active': alignment === -1
    });
    const neutralButtonClassName = classnames(buttonClassName, 'opinion-toggle--neutral', {
      'is-active': alignment === 0
    });

    if (session && arguable) {
      return (
        <div className="opinion-toggle button-group">
          <button
            className={okButtonClassName}
            onClick={() => this.setState({ alignment: 1 })}
          >
            <Icon name="icon-thumb-up" />
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
          </button>
        </div>
      );
    }

    return null;
  }

  /**
   * Render a select with an option for each user's verified group
   * @private
   * @returns {Void|DOMElement} - Returns nothing or a form field.
   */
  _renderCommentAs() {
    const { session, commentable: { id, type } } = this.props;
    const { user, verifiedUserGroups } = session;

    if (verifiedUserGroups.length > 0) {
      return (
        <div className="field">
          <label htmlFor={`add-comment-${type}-${id}-user-group-id`}>
            { I18n.t('components.add_comment_form.form.user_group_id.label') }
          </label>
          <select
            ref={(select) => {this.userGroupIdSelect = select}}
            id={`add-comment-${type}-${id}-user-group-id`}
          >
            <option value="">{ user.name }</option>
            {
              verifiedUserGroups.map((userGroup) => (
                <option key={userGroup.id} value={userGroup.id}>{userGroup.name}</option>
              ))
            }
          </select>
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
    const { maxLength } = this.props;
    this.setState({ disabled: body === '', error: body === '' || body.length > maxLength });
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
    let addCommentParams = { body: this.bodyTextArea.value, alignment };

    evt.preventDefault();

    if (this.userGroupIdSelect && this.userGroupIdSelect.value !== '') {
      addCommentParams.userGroupId = this.userGroupIdSelect.value;
    }

    addComment(addCommentParams);

    this.bodyTextArea.value = '';
    this.setState({ alignment: 0 });

    if (onCommentAdded) {
      onCommentAdded();
    }
  }
}

AddCommentForm.propTypes = {
  addComment: PropTypes.func.isRequired,
  session: PropTypes.shape({
    user: PropTypes.shape({
      name: PropTypes.string.isRequired
    }),
    verifiedUserGroups: PropTypes.arrayOf(
      PropTypes.shape({
        name: PropTypes.string.isRequired
      })
    ).isRequired
  }),
  commentable: PropTypes.shape({
    id: PropTypes.string.isRequired,
    type: PropTypes.string.isRequired
  }),
  showTitle: PropTypes.bool.isRequired,
  submitButtonClassName: PropTypes.string.isRequired,
  onCommentAdded: PropTypes.func,
  arguable: PropTypes.bool,
  autoFocus: PropTypes.bool,
  maxLength: PropTypes.number.isRequired
};

AddCommentForm.defaultProps = {
  onCommentAdded: function() {},
  showTitle: true,
  submitButtonClassName: 'button button--sc',
  arguable: false,
  autoFocus: false,
  maxLength: 1000
};

AddCommentForm.fragments = {
  session: gql`
    ${addCommentFormSessionFragment}
  `,
  commentable: gql`
    ${addCommentFormCommentableFragment}
  `
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
    addComment: ({ body, alignment, userGroupId }) => mutate({
      variables: {
        commentableId: ownProps.commentable.id,
        commentableType: ownProps.commentable.type,
        body,
        alignment,
        userGroupId
      },
      optimisticResponse: {
        commentable: {
          __typename: 'CommentableMutation',
          addComment: {
            __typename: 'Comment',
            id: uuid(),
            type: "Decidim::Comments::Comment",
            createdAt: new Date().toISOString(),
            body,
            alignment: alignment,
            author: {
              __typename: 'User',
              name: ownProps.session.user.name,
              avatarUrl: ownProps.session.user.avatarUrl
            },
            comments: [],
            hasComments: false,
            acceptsNewComments: false,
            upVotes: 0,
            upVoted: false,
            downVotes: 0,
            downVoted: false
          }
        }
      },
      updateQueries: {
        GetComments: (prev, { mutationResult: { data } }) => {
          const { id, type } = ownProps.commentable;
          const newComment = data.commentable.addComment;
          let comments = [];

          const commentReducer = (comment) => {
            const replies = comment.comments || [];

            if (comment.id === id) {
              return {
                ...comment,
                hasComments: true,
                comments: [
                  ...replies,
                  newComment
                ]
              };
            }
            return {
              ...comment,
              comments: replies.map(commentReducer)
            };
          };

          if (type === "Decidim::Comments::Comment") {
            comments = prev.commentable.comments.map(commentReducer);
          } else {
            comments = [
              ...prev.commentable.comments,
              newComment
            ];
          }

          return {
            ...prev,
            commentable: {
              ...prev.commentable,
              comments
            }
          };
        }
      }
    })
  })
})(AddCommentForm);

export default AddCommentFormWithMutation;
