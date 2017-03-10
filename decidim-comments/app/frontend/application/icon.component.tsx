import * as React from 'react';
import assetUrl   from '../support/asset_url';

interface IconProps {
  name: string;
  userAgent: string;
  iconExtraClassName?: string;
}

export const Icon: React.SFC<IconProps> = ({ name, userAgent, iconExtraClassName }) => {
  if (userAgent.match(/PhantomJS/) || userAgent.match(/Node/)) {
    return <span className={`icon ${iconExtraClassName} ${name}`}>{name}</span>;
  }

  return (
    <svg className={`icon ${iconExtraClassName} ${name}`}>
      <use xmlnsXlink="http://www.w3.org/1999/xlink" xlinkHref={`${assetUrl('icons.svg')}#${name}`} />
    </svg>
  );
};

Icon.defaultProps = {
  iconExtraClassName: 'icon--before'
};

interface IconWithoutUserAgentProps {
  name: string;
  iconExtraClassName?: string;
}

const IconWithoutUserAgent: React.SFC<IconWithoutUserAgentProps> = ({ name, iconExtraClassName }) => (
  <Icon name={name} userAgent={navigator.userAgent} iconExtraClassName={iconExtraClassName} />
);

export default IconWithoutUserAgent;
