import * as React from "react";

const { I18n } = require("react-i18nify");

interface CommentOrderSelectorProps {
  defaultOrderBy: string;
  reorderComments: (orderBy: string) => void;
}

interface CommentOrderSelectorState {
  orderBy: string;
}

/**
 * A simple static component with the comment's order selector markup
 * @class
 * @augments Component
 * @todo Needs a proper implementation
 */
class CommentOrderSelector extends React.Component<CommentOrderSelectorProps, CommentOrderSelectorState> {
  private dropdown: HTMLUListElement;

  constructor(props: CommentOrderSelectorProps) {
    super(props);

    this.state = {
      orderBy: this.props.defaultOrderBy,
    };
  }

  public setDropdown = (dropdown: HTMLUListElement) => this.dropdown = dropdown;

  public componentDidMount() {
    window.$(this.dropdown).foundation();
  }

  public render() {
    const { orderBy } =  this.state;

    return (
      <div className="order-by__dropdown order-by__dropdown--right">
        <span className="order-by__text">{I18n.t("components.comment_order_selector.title")}</span>
        <ul
          className="dropdown menu"
          data-dropdown-menu="data-dropdown-menu"
          data-close-on-click-inside="false"
          ref={this.setDropdown}
        >
          <li>
            <a>{I18n.t(`components.comment_order_selector.order.${orderBy}`)}</a>
            <ul className="menu">
              <li>
                <a href="" className="test" onClick={this.updateOrder("best_rated")} >
                  {I18n.t("components.comment_order_selector.order.best_rated")}
                </a>
              </li>
              <li>
                <a href="" onClick={this.updateOrder("recent")} >
                  {I18n.t("components.comment_order_selector.order.recent")}
                </a>
              </li>
              <li>
                <a href="" onClick={this.updateOrder("older")} >
                  {I18n.t("components.comment_order_selector.order.older")}
                </a>
              </li>
              <li>
                <a href="" onClick={this.updateOrder("most_discussed")} >
                  {I18n.t("components.comment_order_selector.order.most_discussed")}
                </a>
              </li>
            </ul>
          </li>
        </ul>
      </div>
    );
  }

  private updateOrder = (orderBy: string) => {
    return (event: React.MouseEvent<HTMLAnchorElement>) => {
      event.preventDefault();
      this.setState({ orderBy });
      this.props.reorderComments(orderBy);
    };
  }
}

export default CommentOrderSelector;
