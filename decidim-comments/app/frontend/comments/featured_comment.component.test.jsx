import { shallow }     from 'enzyme';
import FeaturedComment from './featured_comment.component';

describe('<FeaturedComment />', () => {
  it("should render a section of class comments", () => {
    const wrapper = shallow(<FeaturedComment />);
    expect(wrapper.find('section.comments')).to.be.present();
  });
});
