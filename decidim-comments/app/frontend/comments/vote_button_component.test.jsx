/* eslint-disable no-unused-expressions */
import { shallow } from 'enzyme';

import VoteButton  from './vote_button.component';
import Icon        from '../application/icon.component';

import stubComponent from '../support/stub_component';

describe("<VoteButton />", () => {
  const voteAction = sinon.spy();
  stubComponent(Icon);

  it("should render the number of votes passed as a prop", () => {
    const wrapper = shallow(<VoteButton votes={10} buttonClassName="vote-button" iconName="vote-icon" voteAction={voteAction} />);
    expect(wrapper.find('button')).to.include.text(10);
  });

  it("should render a button with the given buttonClassName", () => {
    const wrapper = shallow(<VoteButton votes={10} buttonClassName="vote-button" iconName="vote-icon" voteAction={voteAction} />);
    expect(wrapper.find('button.vote-button')).to.be.present();
  });

  it("should render a Icon component with the correct name prop", () => {
    const wrapper = shallow(<VoteButton votes={10} buttonClassName="vote-button" iconName="vote-icon" voteAction={voteAction} />); 
    expect(wrapper.find(Icon)).to.have.prop("name").equal('vote-icon');
  });

  it("should call the voteAction prop on click", () => {
    const wrapper = shallow(<VoteButton votes={10} buttonClassName="vote-button" iconName="vote-icon" voteAction={voteAction} />);
    wrapper.find('button').simulate('click');
    expect(voteAction).to.have.been.called;
  });

  it("should disable the button based on the disabled prop", () => {
    const wrapper = shallow(<VoteButton votes={10} buttonClassName="vote-button" iconName="vote-icon" voteAction={voteAction} disabled />);    
    expect(wrapper.find('button')).to.be.disabled();
  })
});
