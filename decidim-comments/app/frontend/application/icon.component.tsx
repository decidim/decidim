import * as React from "react";
import assetUrl from "../support/asset_url";

interface IconProps {
  name: string;
  title?: string;
  iconExtraClassName?: string;
  role?: string;
}

export const Icon: React.SFC<IconProps> = ({ name, title, iconExtraClassName, role = "none presentation" }) => {
  let titleElement = null;
  if (title) {
    titleElement = <title>{title}</title>;
  }

  return (
    <svg className={`icon ${iconExtraClassName} ${name}`} role={role}>
      {titleElement}
      <use
        xmlnsXlink="http://www.w3.org/1999/xlink"
        xlinkHref={`${assetUrl("icons.svg")}#${name}`}
      />
    </svg>
  );
};

Icon.defaultProps = {
  iconExtraClassName: "icon--before"
};

interface IconWithoutUserAgentProps {
  name: string;
  title?: string;
  iconExtraClassName?: string;
  role?: string;
}

const IconWithoutUserAgent: React.SFC<IconWithoutUserAgentProps> = ({
  name,
  title,
  iconExtraClassName,
  role = "none presentation"
}) => <Icon name={name} title={title} iconExtraClassName={iconExtraClassName} role={role} />;

export default IconWithoutUserAgent;
