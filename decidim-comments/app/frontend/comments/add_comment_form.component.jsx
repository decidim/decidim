/* eslint-disable no-return-assign, react/no-unused-prop-types */
import { Component, PropTypes } from 'react';
import { graphql }              from 'react-apollo';
import gql                      from 'graphql-tag';
import { random }               from 'faker/locale/en';
import { I18n }                 from 'react-i18nify';

import addCommentMutation       from './add_comment_form.mutation.graphql';

/**
 * Renders a form to create new comments.
 */
export class AddCommentForm extends Component {
  constructor(props) {
    super(props);

    this.state = {
      disabled: true
    };
  }

  render() {
    const { disabled } = this.state;
    
    return (
      <div className="add-comment">
        {this._renderHeading()}
        <form onSubmit={(evt) => this._addComment(evt)}>
          <label className="show-for-sr" htmlFor="add-comment">{ I18n.t("components.add_comment_form.form.body.label") }</label>
          <textarea
            ref={(textarea) => this.bodyTextArea = textarea}
            id="add-comment"
            rows="4"
            placeholder={I18n.t("components.add_comment_form.form.body.placeholder")}
            onChange={(evt) => this._checkCommentBody(evt.target.value)}
          />
          <input 
            type="submit"
            className="button button--sc"
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
    const { addComment } = this.props;
    addComment({ body: this.bodyTextArea.value });
    this.bodyTextArea.value = '';
    evt.preventDefault();
  }
}

AddCommentForm.defaultProps = {
  showTitle: true
};

AddCommentForm.propTypes = {
  addComment: PropTypes.func.isRequired,
  currentUser: PropTypes.shape({
    name: PropTypes.string.isRequired
  }).isRequired,
  commentableId: PropTypes.string.isRequired,
  commentableType: PropTypes.string.isRequired,
  showTitle: PropTypes.bool.isRequired
};

const AddCommentFormWithMutation = graphql(gql`
  ${addCommentMutation}
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
          id: random.uuid(),
          createdAt: (new Date()).toString(),
          body,
          author: {
            __typename: 'Author',
            name: ownProps.currentUser.name
          }
        }
      },
      updateQueries: {
        GetComments: (prev, { mutationResult: { data } }) => {
          const comment = data.addComment;
          return {
            comments: [
              ...prev.comments,
              comment
            ]
          };
        }
      }
    })
  })
})(AddCommentForm);

export default AddCommentFormWithMutation;
