import { shallow }   from 'enzyme';
import CommentThread from './comment_thread.component';
import Comment       from './comment.component';

describe('<CommentThread />', () => {
  it("should have a descendant h6 of class comment-thread__title", () => {
    const wrapper = shallow(<CommentThread />);
    expect(wrapper).to.have.descendants('h6.comment-thread__title');
  });

  it("should have a descendant div of class comment-thread", () => {
    const wrapper = shallow(<CommentThread />);
    expect(wrapper).to.have.descendants('div.comment-thread');
  }); 

  it("should have a descendant Comment", () => {
    const wrapper = shallow(<CommentThread />);
    expect(wrapper).to.have.descendants(Comment);
  });  
});
