import * as React from "react";
import Icon from "../application/icon.component";

interface VoteButtonProps {
  buttonClassName: string;
  iconName: string;
  text: string;
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
  text,
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
    title={text}
    data-open={userLoggedIn ? null : "loginModal"}
  >
    <span className="show-for-sr">{text}</span>
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
