import { Component, PropTypes } from 'react';
import Icon          from '../application/icon.component';

class VoteButton extends Component {
  render() {
    const { buttonClassName, iconName, votes, voteAction, disabled, selectedClass } = this.props;
    let voteClasses = `${buttonClassName} ${selectedClass}`;

    return (
      <button className={voteClasses} onClick={() => voteAction()} disabled={disabled}>
        <Icon name={iconName} iconExtraClassName="icon--small" />
        { ` ${votes}` }
      </button>
    );
  }
}

VoteButton.propTypes = {
  buttonClassName: PropTypes.string.isRequired,
  iconName: PropTypes.string.isRequired,
  votes: PropTypes.number.isRequired,
  voteAction: PropTypes.func.isRequired,
  selectedClass: PropTypes.string,
  disabled: PropTypes.bool
};

export default VoteButton;
