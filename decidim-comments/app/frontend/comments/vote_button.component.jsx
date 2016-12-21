import { PropTypes } from 'react';
import Icon          from '../application/icon.component';

const VoteButton = ({ buttonClassName, iconName, votes, voteAction, disabled }) => (
  <button className={buttonClassName} onClick={() => voteAction()} disabled={disabled}>
    <Icon name={iconName} iconExtraClassName="icon--small" />
    { ` ${votes}` }
  </button>
);

VoteButton.propTypes = {
  buttonClassName: PropTypes.string.isRequired,
  iconName: PropTypes.string.isRequired,
  votes: PropTypes.number.isRequired,
  voteAction: PropTypes.func.isRequired,
  disabled: PropTypes.bool
};

export default VoteButton;
