import * as React from "react";
import * as ReactDOM from "react-dom";

import Comments, { CommentsApplicationProps } from "./comments/comments.component";
import loadTranslations from "./support/load_translations";

window.DecidimComments = window.DecidimComments || {};

interface StorageDict {
  [key: string]: string;
}

window.DecidimComments.renderCommentsComponent = (nodeId: string, props: CommentsApplicationProps) => {
  const node = window.$(`#${nodeId}`)[0];
  const queryDict: StorageDict = {};
  window
    .location
    .search
    .substr(1)
    .split("&")
    .forEach(item => queryDict[item.split("=")[0]] = item.split("=")[1]);

  props = { ...props, singleCommentId: queryDict.commentId };

  ReactDOM.render(
    React.createElement(Comments, props),
    node
  );

  if (queryDict.commentId) {
    $([document.documentElement, document.body]).animate({
      scrollTop: $("#comments").offset()!.top
    }, 2000);
  }
};

// Load component locales from yaml files
loadTranslations();
