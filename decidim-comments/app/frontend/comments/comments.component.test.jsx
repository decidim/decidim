import { shallow } from 'enzyme';
import Comments    from './comments.component';

describe('<Comments />', () => {
  it("renders a div of id comments", () => {
    const wrapper = shallow(<Comments />);
    expect(wrapper.find('#comments')).to.be.present();
  })
});
