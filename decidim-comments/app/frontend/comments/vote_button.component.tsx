import * as React from "react";
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

const preventDefault = (event: any) => {
  event.preventDefault();
};

const VoteButton: React.SFC<VoteButtonProps> = ({
  buttonClassName,
  iconName,
  votes,
  voteAction,
  disabled,
  selectedClass,
  userLoggedIn
}) => (
  <button
    className={`${buttonClassName} ${selectedClass}`}
    onClick={userLoggedIn ? voteAction : preventDefault}
    disabled={disabled}
    data-open={userLoggedIn ? null : "loginModal"}
  >
    <Icon name={iconName} iconExtraClassName="icon--small" />
    {` ${votes}`}
  </button>
);

VoteButton.defaultProps = {
  buttonClassName: "",
  iconName: "",
  votes: 0,
  selectedClass: "selected",
  disabled: false
};

export default VoteButton;
