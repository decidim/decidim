import * as React from "react";
import * as ReactDOM    from "react-dom";

import Comments, { CommentsApplicationProps } from "./comments/comments.component";
import loadTranslations from "./support/load_translations";

window.DecidimComments = window.DecidimComments || {};

window.DecidimComments.renderCommentsComponent = (nodeId: string, props: CommentsApplicationProps) => {
  let node = window.$(`#${nodeId}`)[0];

  ReactDOM.render(
    React.createElement(Comments, props),
    node,
  );
};

// Load component locales from yaml files
loadTranslations();
