import * as React from "react";
import * as ReactDOM from "react-dom";

import Comments, { CommentsApplicationProps } from "./comments/comments.component";
import loadTranslations from "./support/load_translations";

window.DecidimComments = window.DecidimComments || {};

type Dict = { [key: string]: string }

window.DecidimComments.renderCommentsComponent = (nodeId: string, props: CommentsApplicationProps) => {
  const node = window.$(`#${nodeId}`)[0];
  let queryDict: Dict = {}
  window
    .location
    .search
    .substr(1)
    .split("&")
    .forEach(function (item) { queryDict[item.split("=")[0]] = item.split("=")[1] })

  props = { ...props, singleCommentId: queryDict.commentId }

  ReactDOM.render(
    React.createElement(Comments, props),
    node
  );
};

// Load component locales from yaml files
loadTranslations();
