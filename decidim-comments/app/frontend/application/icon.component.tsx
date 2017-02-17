import * as React from 'react';
import assetUrl   from '../support/asset_url';

interface IconProps {
  name: string;
  iconExtraClassName?: string;
}

const Icon: React.SFC<IconProps> = ({ name, iconExtraClassName }) => {
  if (navigator.userAgent.match(/PhantomJS/)) {
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

export default Icon;
