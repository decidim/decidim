import * as React from "react";
import * as ReactDOM from "react-dom";

import CommentsApplication, { CommentsApplicationProps } from "./comments/comments_application.component";
import loadTranslations from "./support/load_translations";

window.DecidimComments = window.DecidimComments || {};

window.DecidimComments.renderCommentsComponent = (nodeId: string, props: CommentsApplicationProps) => {
  const node = window.$(`#${nodeId}`)[0];

  ReactDOM.render(
    React.createElement(CommentsApplication, props),
    node,
  );
};

// Load component locales from yaml files
loadTranslations();
