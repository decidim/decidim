import { PropTypes } from 'react';

import assetUrl      from '../support/asset_url';

const Icon = ({ name }) => {
  if (navigator.userAgent.match(/PhantomJS/)) {
    return <span>{name}</span>;
  }

  return (
    <svg className={`icon icon--before ${name}`}>
      <use xmlnsXlink="http://www.w3.org/1999/xlink" xlinkHref={`${assetUrl('icons.svg')}#${name}`} />
    </svg>  
  );
};

Icon.propTypes = {
  name: PropTypes.string.isRequired
};

export default Icon;
