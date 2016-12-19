import ReactDOM         from 'react-dom';

import loadTranslations from './support/load_translations';
import Comments         from './comments/comments.component';

// Expose global components
window.DecidimComments.renderCommentsComponent = (nodeId, props) => {
  var node = $(`#${nodeId}`)[0];

  ReactDOM.render(
    React.createElement(Comments,props),
    node
  );

  function unmountComponent() {
    ReactDOM.unmountComponentAtNode(node);
    $(document).off('turbolinks:before-render', unmountComponent);
  }

  $(document).on('turbolinks:before-render', unmountComponent);
};

// Load component locales from yaml files
loadTranslations();
