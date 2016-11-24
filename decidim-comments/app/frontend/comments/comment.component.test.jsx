import { shallow } from 'enzyme';
import Comment     from './comment.component';

describe("<Comment />", () => {
  it("renders an article with class comment", () => {
    const wrapper = shallow(<Comment />);
    expect(wrapper.find('article.comment')).to.present();
  });
});
