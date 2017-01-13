import { Component } from 'react';
import { I18n }      from 'react-i18nify';

/**
 * A simple static component with the comment's order selector markup
 * @class
 * @augments Component
 * @todo Needs a proper implementation
 */
class CommentOrderSelector extends Component {
  componentDidMount() {
    $(document).foundation();
  }
  render() {
    return (
      <div className="order-by__dropdown order-by__dropdown--right">
        <span className="order-by__text">{ I18n.t("components.comment_order_selector.title") }</span>
        <ul className="dropdown menu" data-dropdown-menu>
          <li>
            <a>{ I18n.t("components.comment_order_selector.order.most_voted") }</a>
            <ul className="menu">
              <li><a>{ I18n.t("components.comment_order_selector.order.most_voted") }</a></li>
              <li><a>{ I18n.t("components.comment_order_selector.order.recent") }</a></li>
              <li><a>{ I18n.t("components.comment_order_selector.order.older") }</a></li>
            </ul>
          </li>
        </ul>
      </div>
    );
  }
}

export default CommentOrderSelector;
