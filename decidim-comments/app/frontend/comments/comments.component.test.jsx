import { shallow }  from 'enzyme';
import { Comments } from './comments.component';

describe('<Comments />', () => {
  it("renders a div of id comments", () => {
    const data = {};
    const wrapper = shallow(<Comments data={data} />);
    expect(wrapper.find('#comments')).to.be.present();
  })
});
