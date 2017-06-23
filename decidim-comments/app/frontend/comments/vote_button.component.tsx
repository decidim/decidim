import * as React from "react";
import { compose, withHandlers } from "recompose";
import Icon from "../application/icon.component";

interface VoteButtonProps {
  buttonClassName: string;
  iconName: string;
  votes: number;
  voteAction?: () => void;
  disabled?: boolean;
  selectedClass?: string;
  userLoggedIn: boolean;
}

interface EnhancedVoteButtonProps {
  onClick: (event: any) => void;
}

const VoteButton: React.SFC<VoteButtonProps & EnhancedVoteButtonProps> = ({
  buttonClassName,
  iconName,
  votes,
  disabled,
  selectedClass,
  userLoggedIn,
  onClick,
}) => (
  <button
    className={`${buttonClassName} ${selectedClass}`}
    onClick={onClick}
    disabled={disabled}
    data-open={userLoggedIn ? null : "loginModal"}
  >
    <Icon name={iconName} iconExtraClassName="icon--small" />
    {` ${votes}`}
  </button>
);

VoteButton.defaultProps = {
  selectedClass: "selected",
  disabled: false,
};

const enhance = compose<VoteButtonProps, VoteButtonProps>(
  withHandlers<VoteButtonProps, VoteButtonProps>({
    onClick: ({ userLoggedIn, voteAction }) => (event: any) => (
      userLoggedIn ? voteAction : event.preventDefault()
    ),
  }),
);

export default enhance(VoteButton);
