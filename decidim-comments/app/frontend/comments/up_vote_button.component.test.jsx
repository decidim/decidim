import { shallow }          from 'enzyme';
import { filter }           from 'graphql-anywhere';
import gql                  from 'graphql-tag';

import { UpVoteButton }     from './up_vote_button.component';

import VoteButton           from './vote_button.component';

import upVoteFragment       from './up_vote.fragment.graphql';

import stubComponent        from '../support/stub_component';
import generateCommentsData from '../support/generate_comments_data';

describe("<UpVoteButton />", () => {
  let comment = {};
  const upVote = () => {};

  stubComponent(VoteButton);

  beforeEach(() => {
    let commentsData = generateCommentsData(1);
    
    const fragment = gql`
      ${upVoteFragment}
    `;

    comment = filter(fragment, commentsData[0]);
  });

  it("should render a VoteButton component with the correct props", () => {
    const wrapper = shallow(<UpVoteButton comment={comment} upVote={upVote} />);
    expect(wrapper.find(VoteButton)).to.have.prop("buttonClassName").equal("comment__votes--up");
    expect(wrapper.find(VoteButton)).to.have.prop("iconName").equal("icon-chevron-top");
    expect(wrapper.find(VoteButton)).to.have.prop("votes").equal(comment.upVotes);    
  });

  it("should pass disabled prop as true if comment upVoted is true", () => {
    comment.upVoted = true;
    const wrapper = shallow(<UpVoteButton comment={comment} upVote={upVote} />);
    expect(wrapper.find(VoteButton)).to.have.prop("disabled").equal(true);        
  });

  it("should pass disabled prop as true if comment downVoted is true", () => {
    comment.downVoted = true;
    const wrapper = shallow(<UpVoteButton comment={comment} upVote={upVote} />);
    expect(wrapper.find(VoteButton)).to.have.prop("disabled").equal(true);        
  });
});
