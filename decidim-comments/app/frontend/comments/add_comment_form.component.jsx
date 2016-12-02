/* eslint-disable no-return-assign, react/no-unused-prop-types */
import { Component, PropTypes } from 'react';
import { graphql }              from 'react-apollo';
import gql                      from 'graphql-tag';
import { random }               from 'faker/locale/en';
import { I18n }                 from 'react-i18nify';

import Translatable             from '../application/translatable';

import addCommentMutation       from './add_comment_form.mutation.graphql';

@Translatable()
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
        <h5 className="section-heading">{ I18n.t("add_comment_form.title") }</h5>
        <form onSubmit={(evt) => this._addComment(evt)}>
          <label className="show-for-sr" htmlFor="add-comment">{ I18n.t("add_comment_form.form.body.label") }</label>
          <textarea
            ref={(textarea) => this.bodyTextArea = textarea}
            id="add-comment"
            rows="4"
            placeholder={I18n.t("add_comment_form.form.body.placeholder")}
            onChange={(evt) => this._checkCommentBody(evt.target.value)}
          />
          <input 
            type="submit"
            className="button button--sc"
            value={I18n.t("add_comment_form.form.submit")}
            disabled={disabled}
          />
        </form>
      </div>
    );
  }

  _checkCommentBody(body) {
    this.setState({ disabled: body === '' });
  }

  _addComment(evt) {
    const { addComment } = this.props;
    addComment({ body: this.bodyTextArea.value });
    this.bodyTextArea.value = '';
    evt.preventDefault();
  }
}

AddCommentForm.propTypes = {
  addComment: PropTypes.func.isRequired,
  session: PropTypes.shape({
    currentUser: PropTypes.shape({
      id: React.PropTypes.oneOfType([
        PropTypes.string,
        PropTypes.number
      ]),
      name: PropTypes.string.isRequired
    }).isRequired
  }).isRequired,
  commentableId: PropTypes.string.isRequired,
  commentableType: PropTypes.string.isRequired
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
            name: ownProps.session.currentUser.name
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
