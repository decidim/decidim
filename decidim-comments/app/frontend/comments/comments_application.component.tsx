import * as React from "react";
import Application from "../application/application.component";
import Comments, { CommentsProps } from "./comments.component";

export type CommentsApplicationProps = CommentsProps & {
  locale: string;
};

/**
 * Wrap the CommentsWithData component within an Application component to
 * connect it with Apollo client and store.
 * @returns {ReactComponent} - A component wrapped within an Application component
 */
const CommentsApplication: React.SFC<CommentsApplicationProps> = ({ locale, commentableId, commentableType }) => (
  <Application locale={locale}>
    <Comments commentableId={commentableId} commentableType={commentableType} orderBy="older" />
  </Application>
);

export default CommentsApplication;
