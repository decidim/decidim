import { shallow }           from 'enzyme';
import { filter }            from 'graphql-anywhere';
import gql                   from 'graphql-tag';

import Comment               from './comment.component';

import commentFragment       from './comment.fragment.graphql'

import generateCommentsData  from '../support/generate_comments_data';

describe("<Comment />", () => {
  let comment = {};

  beforeEach(() => {
    const commentsData = generateCommentsData(1);
    
    const fragment = gql`
      ${commentFragment}
    `;

    comment = filter(fragment, commentsData.comments[0]);
  });

  it("should render an article with class comment", () => {
    const wrapper = shallow(<Comment comment={comment} />);
    expect(wrapper.find('article.comment')).to.present();
  });

  it("should render a time tag with comment's created at", () => {
    const wrapper = shallow(<Comment comment={comment} />);
    expect(wrapper.find('time')).to.have.text(comment.created_at);
  });

  it("should render author's name in a link with class author__name", () => {
    const wrapper = shallow(<Comment comment={comment} />);
    expect(wrapper.find('a.author__name')).to.have.text(comment.author.name);
  });

  it("should render comment's body on a div with class comment__content", () => {
    const wrapper = shallow(<Comment comment={comment} />);
    expect(wrapper.find('div.comment__content')).to.have.text(comment.body);
  });
});
