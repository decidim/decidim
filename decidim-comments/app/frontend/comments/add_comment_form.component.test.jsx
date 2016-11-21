import { shallow }    from 'enzyme';
import AddCommentForm from './add_comment_form.component';

describe("<AddCommentForm />", () => {
  it("renders an div with class add-comment", () => {
    const wrapper = shallow(<AddCommentForm />);
    expect(wrapper.find('div.add-comment')).to.present();
  });
});
