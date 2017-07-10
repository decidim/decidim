import * as React from "react";
import { compose, defaultProps, withHandlers, withProps } from "recompose";
import Icon from "../application/icon.component";

export interface VoteButtonProps {
  buttonClassName: string;
  iconName: string;
  votes: number;
  voteAction: () => void;
  disabled?: boolean;
  selectedClass?: string;
  userLoggedIn: boolean;
}

interface WithProps {
  className: string;
  openModal: string | null;
}

interface WithHandlersProps {
  onClick: (event: any) => void;
}

type EnhancedProps = VoteButtonProps & WithProps & WithHandlersProps;

const VoteButton: React.SFC<EnhancedProps> = ({
  className,
  onClick,
  disabled,
  openModal,
  iconName,
  votes,
}) => (
  <button className={className} onClick={onClick} disabled={disabled} data-open={openModal}>
    <Icon name={iconName} iconExtraClassName="icon--small" />
    {` ${votes}`}
  </button>
);

const enhance = compose<VoteButtonProps, VoteButtonProps>(
  defaultProps({
    selectedClass: "selected",
    disabled: false,
  }),
  withProps<WithProps, VoteButtonProps>(
    ({ buttonClassName, selectedClass, userLoggedIn }) => ({
      className: `${buttonClassName} ${selectedClass}`,
      openModal: userLoggedIn ? null : "loginModal",
    }),
  ),
  withHandlers<VoteButtonProps, VoteButtonProps>({
    onClick: ({ userLoggedIn, voteAction }) => (event: any) => {
      userLoggedIn ? voteAction() : event.preventDefault();
    },
  }),
);

export default enhance(VoteButton);
