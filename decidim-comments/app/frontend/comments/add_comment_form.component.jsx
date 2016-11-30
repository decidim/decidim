/* eslint-disable no-return-assign */
import { Component, PropTypes } from 'react';
import { graphql }              from 'react-apollo';
import gql                      from 'graphql-tag';

import addCommentMutation       from './add_comment_form.mutation.graphql';

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
        <h5 className="section-heading">Deixa el teu comentari</h5>
        <form onSubmit={(evt) => this._addComment(evt)}>
          <label className="show-for-sr" htmlFor="add-comment">Comentari</label>
          <textarea
            ref={(textarea) => this.bodyTextArea = textarea}
            id="add-comment"
            rows="4"
            placeholder="Què opines d'aquesta proposta?"
            onChange={(evt) => this._checkCommentBody(evt.target.value)}
          />
          <input 
            type="submit"
            className="button button--sc"
            value="Enviar"
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
  addComment: PropTypes.func.isRequired
};

const AddCommentFormWithMutation = graphql(gql`
  ${addCommentMutation}
`, {
  props: ({ mutate }) => ({
    addComment: ({ body }) => mutate({ variables: { body }})
  })
})(AddCommentForm);

export default AddCommentFormWithMutation;
