import { shallow }     from 'enzyme';

import FeaturedComment from './featured_comment.component';
import { Comment }     from './comment.component';

import stubComponent   from '../support/stub_component';

describe('<FeaturedComment />', () => {
  stubComponent(Comment);

  it("should render a section of class comments", () => {
    const wrapper = shallow(<FeaturedComment />);
    expect(wrapper.find('section.comments')).to.be.present();
  });
});
