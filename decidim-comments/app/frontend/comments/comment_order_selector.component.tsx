import * as React from "react";
import { compose, lifecycle, withHandlers, withState } from "recompose";
const { I18n } = require("react-i18nify");

interface CommentOrderSelectorProps {
  defaultOrderBy: string;
  reorderComments: (orderBy: string) => void;
}

interface WithStateProps {
  orderBy: string;
  setOrderBy: (orderBy: string) => void;
  setRef: (ref: HTMLUListElement) => void;
}

interface WithHandlersProps {
  updateOrder: (orderBy: string) => (event: any) => void;
}

type EnhancedProps = CommentOrderSelectorProps & WithStateProps & WithHandlersProps;

let dropdown: HTMLUListElement;

const CommentOrderSelector: React.SFC<EnhancedProps> = ({
  orderBy,
  setRef,
  updateOrder,
}) => (
  <div className="order-by__dropdown order-by__dropdown--right">
    <span className="order-by__text">{I18n.t("components.comment_order_selector.title")}</span>
    <ul
      className="dropdown menu"
      data-dropdown-menu="data-dropdown-menu"
      ref={setRef}
    >
      <li>
        <a>{I18n.t(`components.comment_order_selector.order.${orderBy}`)}</a>
        <ul className="menu">
          <li>
            <a href="" className="test" onClick={updateOrder("best_rated")} >
              {I18n.t("components.comment_order_selector.order.best_rated")}
            </a>
          </li>
          <li>
            <a href="" onClick={updateOrder("recent")} >
              {I18n.t("components.comment_order_selector.order.recent")}
            </a>
          </li>
          <li>
            <a href="" onClick={updateOrder("older")} >
              {I18n.t("components.comment_order_selector.order.older")}
            </a>
          </li>
          <li>
            <a href="" onClick={updateOrder("most_discussed")} >
              {I18n.t("components.comment_order_selector.order.most_discussed")}
            </a>
          </li>
        </ul>
      </li>
    </ul>
  </div>
);

const enhance = compose<CommentOrderSelectorProps, CommentOrderSelectorProps>(
  withState("orderBy", "setOrderBy", (ownProps: CommentOrderSelectorProps) => ownProps.defaultOrderBy),
  withHandlers({
    updateOrder: (props: CommentOrderSelectorProps & WithStateProps) => (orderBy: string) => (event: any) => {
      event.preventDefault();
      props.setOrderBy(orderBy);
      props.reorderComments(orderBy);
    },
    setRef: () => (ref: HTMLUListElement) => {
      dropdown = ref;
    },
  }),
  lifecycle({
    componentDidMount: () => {
      if (window.$) {
        window.$(dropdown).foundation();
      }
    },
  }),
);

export default enhance(CommentOrderSelector);
