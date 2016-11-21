import { shallow }          from 'enzyme';
import CommentOrderSelector from './comment_order_selector.component';

describe('<CommentOrderSelector />', () => {
  it("renders a div with classes order-by__dropdown order-by__dropdown--right", () => {
    const wrapper = shallow(<CommentOrderSelector />);
    expect(wrapper.find('div.order-by__dropdown.order-by__dropdown--right')).to.present();
  })
})
