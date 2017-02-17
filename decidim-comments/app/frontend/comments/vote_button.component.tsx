import * as React from 'react';
import Icon       from '../application/icon.component';

interface VoteButtonProps {
  buttonClassName: string;
  iconName: string;
  votes: number;
  voteAction: () => void;
  disabled?: boolean;
  selectedClass?: string;
}

const VoteButton: React.SFC<VoteButtonProps> = ({
  buttonClassName,
  iconName,
  votes,
  voteAction,
  disabled,
  selectedClass
}) => (
  <button
    className={`${buttonClassName} ${selectedClass}`}
    onClick={() => voteAction()}
    disabled={disabled}>
    <Icon name={iconName} iconExtraClassName="icon--small" />
    { ` ${votes}` }
  </button>
);

VoteButton.defaultProps = {
  selectedClass: "selected",
  disabled: false
};

export default VoteButton;
