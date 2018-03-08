/* eslint-disable no-return-assign, react/no-unused-prop-types, max-lines */
import * as classnames from "classnames";
import * as React from "react";
import { graphql } from "react-apollo";
import * as uuid from "uuid";

import Icon from "../application/icon.component";

const { I18n, Translate } = require("react-i18nify");

import {
  AddCommentFormCommentableFragment,
  AddCommentFormSessionFragment,
  addCommentMutation,
  CommentFragment,
  GetCommentsQuery
} from "../support/schema";

interface AddCommentFormProps {
  session: AddCommentFormSessionFragment & {
    user: any;
  } | null;
  commentable: AddCommentFormCommentableFragment;
  rootCommentable: AddCommentFormCommentableFragment;
  showTitle?: boolean;
  submitButtonClassName?: string;
  autoFocus?: boolean;
  arguable?: boolean;
  addComment?: (data: { body: string, alignment: number, userGroupId?: string }) => void;
  onCommentAdded?: () => void;
  orderBy: string;
}

interface AddCommentFormState {
  disabled: boolean;
  error: boolean;
  alignment: number;
  remainingCharacterCount: number;
}

export const MAX_LENGTH = 1000;

/**
 * Renders a form to create new comments.
 * @class
 * @augments Component
 */
export class AddCommentForm extends React.Component<AddCommentFormProps, AddCommentFormState> {
  public static defaultProps = {
    showTitle: true,
    submitButtonClassName: "button button--sc",
    arguable: false,
    autoFocus: false
  };

  public bodyTextArea: HTMLTextAreaElement;
  public userGroupIdSelect: HTMLSelectElement;

  constructor(props: AddCommentFormProps) {
    super(props);

    this.state = {
      disabled: true,
      error: false,
      alignment: 0,
      remainingCharacterCount: MAX_LENGTH
    };
  }

  public render() {
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
  private _renderHeading() {
    const { showTitle } = this.props;

    if (showTitle) {
      return (
        <h5 className="section-heading">
          {I18n.t("components.add_comment_form.title")}
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
  private _renderAccountMessage() {
    const { session } = this.props;

    if (!session) {
      return (
        <p>
          <Translate
            value="components.add_comment_form.account_message"
            sign_in_url="/users/sign_in"
            sign_up_url="/users/sign_up"
            dangerousHTML={true}
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
  private _renderForm() {
    const { session, submitButtonClassName, commentable: { id, type } } = this.props;
    const { disabled, remainingCharacterCount } = this.state;

    if (session) {
      return (
        <form onSubmit={this.addComment}>
          {this._renderCommentAs()}
          <div className="field">
            <label className="show-for-sr" htmlFor={`add-comment-${type}-${id}`}>{I18n.t("components.add_comment_form.form.body.label")}</label>
            {this._renderTextArea()}
            {this._renderTextAreaError()}
            <button
              type="submit"
              className={submitButtonClassName}
              disabled={disabled}
            >
              {I18n.t("components.add_comment_form.form.submit")}
            </button>
            <span className="remaining-character-count">
              {I18n.t("components.add_comment_form.remaining_characters", { count:  remainingCharacterCount })}
            </span>
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
  private _renderTextArea() {
    const { commentable: { id, type }, autoFocus } = this.props;
    const { error } = this.state;
    const className = classnames({ "is-invalid-input": error });

    const textAreaProps: any = {
      ref: (textarea: HTMLTextAreaElement) => {this.bodyTextArea = textarea; },
      id: `add-comment-${type}-${id}`,
      className,
      rows: "4",
      maxLength: MAX_LENGTH,
      required: "required",
      pattern: `^(.){0,${MAX_LENGTH}}$`,
      placeholder: I18n.t("components.add_comment_form.form.body.placeholder"),
      onChange: (evt: React.ChangeEvent<HTMLTextAreaElement>) => this._checkCommentBody(evt.target.value)
    };

    if (autoFocus) {
      textAreaProps.autoFocus = "autoFocus";
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
  private _renderTextAreaError() {
    const { error } = this.state;

    if (error) {
      return (
        <span className="form-error is-visible">
          {I18n.t("components.add_comment_form.form.form_error", { length: MAX_LENGTH })}
        </span>
      );
    }

    return null;
  }

  private setAlignment = (alignment: number) => {
    return () => {
      this.setState({ alignment });
    };
  }

  /**
   * Render opinion buttons or not based on the arguable prop
   * @private
   * @returns {Void|DOMElement} - Returns nothing or a wrapper with buttons
   */
  private _renderOpinionButtons() {
    const { session, arguable } = this.props;
    const { alignment } = this.state;
    const buttonClassName = classnames("button", "tiny", "button--muted");
    const okButtonClassName = classnames(buttonClassName, "opinion-toggle--ok", {
      "is-active": alignment === 1
    });
    const koButtonClassName = classnames(buttonClassName, "opinion-toggle--ko", {
      "is-active": alignment === -1
    });
    const neutralButtonClassName = classnames(buttonClassName, "opinion-toggle--meh", {
      "is-active": alignment === 0
    });

    if (session && arguable) {
      return (
        <div className="opinion-toggle button-group">
          <button
            className={okButtonClassName}
            onClick={this.setAlignment(1)}
          >
            <Icon iconExtraClassName="" name="icon-thumb-up" />
          </button>
          <button
            className={neutralButtonClassName}
            onClick={this.setAlignment(0)}
          >
            {I18n.t("components.add_comment_form.opinion.neutral")}
          </button>
          <button
            className={koButtonClassName}
            onClick={this.setAlignment(-1)}
          >
            <Icon iconExtraClassName="" name="icon-thumb-down" />
          </button>
        </div>
      );
    }

    return null;
  }

  private setUserGroupIdSelect = (select: HTMLSelectElement) => {this.userGroupIdSelect = select; };

  /**
   * Render a select with an option for each user's verified group
   * @private
   * @returns {Void|DOMElement} - Returns nothing or a form field.
   */
  private _renderCommentAs() {
    const { session, commentable: { id, type } } = this.props;

    if (session) {
      const { user, verifiedUserGroups } = session;

      if (verifiedUserGroups.length > 0) {
        return (
          <div className="field">
            <label htmlFor={`add-comment-${type}-${id}-user-group-id`}>
              {I18n.t("components.add_comment_form.form.user_group_id.label")}
            </label>
            <select
              ref={this.setUserGroupIdSelect}
              id={`add-comment-${type}-${id}-user-group-id`}
            >
              <option value="">{user.name}</option>
              {
                verifiedUserGroups.map((userGroup) => (
                  <option key={userGroup.id} value={userGroup.id}>{userGroup.name}</option>
                ))
              }
            </select>
          </div>
        );
      }
    }

    return null;
  }

  /**
   * Check comment's body and disable form if it's empty
   * @private
   * @param {string} body - The comment's body
   * @returns {Void} - Returns nothing
   */
  private _checkCommentBody(body: string) {
    this.setState({
      disabled: body === "", error: body === "" || body.length > MAX_LENGTH,
      remainingCharacterCount: MAX_LENGTH - body.length
    });
  }

  /**
   * Handle form's submission and calls `addComment` prop with the value of the
   * form's textarea. It prevents the default form submission event.
   * @private
   * @param {DOMEvent} evt - The form's submission event
   * @returns {Void} - Returns nothing
   */
  private addComment = (evt: React.FormEvent<HTMLFormElement>) => {
    const { alignment } = this.state;
    const { addComment, onCommentAdded } = this.props;
    const addCommentParams: { body: string, alignment: number, userGroupId?: string } = { body: this.bodyTextArea.value, alignment };

    evt.preventDefault();

    if (this.userGroupIdSelect && this.userGroupIdSelect.value !== "") {
      addCommentParams.userGroupId = this.userGroupIdSelect.value;
    }

    if (addComment) {
      addComment(addCommentParams);
    }

    this.bodyTextArea.value = "";
    this.setState({ alignment: 0 });

    if (onCommentAdded) {
      onCommentAdded();
    }
  }
}

const addCommentMutation = require("../mutations/add_comment.mutation.graphql");
const getCommentsQuery = require("../queries/comments.query.graphql");

const AddCommentFormWithMutation = graphql<addCommentMutation, AddCommentFormProps>(addCommentMutation, {
  props: ({ ownProps, mutate }) => ({
    addComment: ({ body, alignment, userGroupId }: { body: string, alignment: number, userGroupId: string }) => {
      if (mutate) {
        mutate({
          variables: {
            commentableId: ownProps.commentable.id,
            commentableType: ownProps.commentable.type,
            body,
            alignment,
            userGroupId
          },
          optimisticResponse: {
            commentable: {
              __typename: "CommentableMutation",
              addComment: {
                __typename: "Comment",
                id: uuid(),
                sgid: uuid(),
                type: "Decidim::Comments::Comment",
                createdAt: new Date().toISOString(),
                body,
                formattedBody: body,
                alignment,
                author: {
                  __typename: "User",
                  name: ownProps.session && ownProps.session.user.name,
                  avatarUrl: ownProps.session && ownProps.session.user.avatarUrl,
                  deleted: false
                },
                comments: [],
                hasComments: false,
                acceptsNewComments: false,
                upVotes: 0,
                upVoted: false,
                downVotes: 0,
                downVoted: false,
                alreadyReported: false
              }
            }
          },
          update: (store, { data }: { data: addCommentMutation }) => {
            const variables = {
              commentableId: ownProps.rootCommentable.id,
              commentableType: ownProps.rootCommentable.type,
              orderBy: ownProps.orderBy
            };
            const prev = store.readQuery<GetCommentsQuery>({
              query: getCommentsQuery,
              variables
             });
            const { id, type } = ownProps.commentable;
            const newComment = data.commentable && data.commentable.addComment;
            let comments = [];

            const commentReducer = (comment: CommentFragment): CommentFragment => {
              const replies = comment.comments || [];

              if (newComment && comment.id === id) {
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

            if (prev) {
              if (type === "Decidim::Comments::Comment") {
                  comments = prev.commentable.comments.map(commentReducer);
                } else {
                  comments = [
                    ...prev.commentable.comments,
                    newComment
                  ];
                }

              store.writeQuery({
                query: getCommentsQuery,
                data: {
                  ...prev,
                  commentable: {
                    ...prev.commentable,
                    totalCommentsCount: prev.commentable.totalCommentsCount + 1,
                    comments
                  }
                },
                variables
              });
            }
          }
        });
      }
    }
  })
})(AddCommentForm);

export default AddCommentFormWithMutation;
