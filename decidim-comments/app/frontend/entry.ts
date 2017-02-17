import * as React from 'react';
import * as ReactDOM    from 'react-dom';

import loadTranslations from './support/load_translations';
import Comments, { CommentsApplicationProps } from './comments/comments.component';

window.DecidimComments = window.DecidimComments || {};

window.DecidimComments.renderCommentsComponent = (nodeId: string, props: CommentsApplicationProps) => {
  var node = $(`#${nodeId}`)[0];

  ReactDOM.render(
    React.createElement(Comments, props),
    node
  );
};

// Load component locales from yaml files
loadTranslations();
