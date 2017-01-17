import { shallow }          from 'enzyme';
import CommentOrderSelector from './comment_order_selector.component';

describe('<CommentOrderSelector />', () => {
  const orderBy = "older";
  const reorderComments = sinon.spy();

  it("renders a div with classes order-by__dropdown order-by__dropdown--right", () => {
    const wrapper = shallow(<CommentOrderSelector reorderComments={reorderComments} defaultOrderBy={orderBy} />);
    expect(wrapper.find('div.order-by__dropdown.order-by__dropdown--right')).to.present();
  })

   it("should set state order to best_rated if user clicks on the first element", () => {
      const preventDefault = sinon.spy();
      const wrapper = shallow(<CommentOrderSelector reorderComments={reorderComments} defaultOrderBy={orderBy} />);
      wrapper.find('a.test').simulate('click', {preventDefault});
      expect(reorderComments).to.calledWith("best_rated");
    });
})

