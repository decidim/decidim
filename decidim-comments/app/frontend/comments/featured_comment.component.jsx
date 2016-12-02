import { Component } from 'react';
import { I18n }      from 'react-i18nify';

import Translatable  from '../application/translatable';

import Comment       from './comment.component';

@Translatable()
export default class FeaturedComment extends Component {
  render() {
    return (
      <section className="comments">
        <h4 className="section-heading">{ I18n.t("featured_comment.title") }</h4>
        <div className="comment-thread comment--pinned">
          <Comment />
        </div>
      </section>
    );
  }
}
