import ReactDOM         from 'react-dom';

import loadTranslations from './support/load_translations';
import Comments         from './comments/comments.component';

// Expose global components
window.DecidimComments.renderCommentsComponent = (nodeId, props) => {
  var node = $(`#${nodeId}`)[0];

  ReactDOM.render(
    React.createElement(Comments, props),
    node
  );
};

// Load component locales from yaml files
loadTranslations();
