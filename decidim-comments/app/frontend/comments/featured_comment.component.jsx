import { Component } from 'react';
import { I18n }      from 'react-i18nify';

import Comment       from './comment.component';

/**
 * A wrapper component for a highlighted component.
 * @class
 * @augments Component
 * @todo It's not used right now
 */
export default class FeaturedComment extends Component {
  render() {
    return (
      <section className="comments">
        <h4 className="section-heading">{ I18n.t("components.featured_comment.title") }</h4>
        <div className="comment-thread comment--pinned">
          <Comment />
        </div>
      </section>
    );
  }
}
