import { shallow }          from 'enzyme';
import { filter }           from 'graphql-anywhere';
import gql                  from 'graphql-tag';

import { DownVoteButton }   from './down_vote_button.component';

import VoteButton           from './vote_button.component';

import downVoteFragment     from './down_vote.fragment.graphql';

import stubComponent        from '../support/stub_component';
import generateCommentsData from '../support/generate_comments_data';

describe("<DownVoteButton />", () => {
  let comment = {};
  const downVote = () => {};

  stubComponent(VoteButton);

  beforeEach(() => {
    let commentsData = generateCommentsData(1);
    
    const fragment = gql`
      ${downVoteFragment}
    `;

    comment = filter(fragment, commentsData[0]);
  });

  it("should render a VoteButton component with the correct props", () => {
    const wrapper = shallow(<DownVoteButton comment={comment} downVote={downVote} />);
    expect(wrapper.find(VoteButton)).to.have.prop("buttonClassName").equal("comment__votes--down");
    expect(wrapper.find(VoteButton)).to.have.prop("iconName").equal("icon-chevron-bottom");
    expect(wrapper.find(VoteButton)).to.have.prop("votes").equal(comment.downVotes);    
  });

  it("should pass disabled prop as true if comment downVoted is true", () => {
    comment.downVoted = true;
    const wrapper = shallow(<DownVoteButton comment={comment} downVote={downVote} />);
    expect(wrapper.find(VoteButton)).to.have.prop("disabled").equal(true);        
  });

  it("should pass disabled prop as true if comment downVoted is true", () => {
    comment.downVoted = true;
    const wrapper = shallow(<DownVoteButton comment={comment} downVote={downVote} />);
    expect(wrapper.find(VoteButton)).to.have.prop("disabled").equal(true);        
  });
});
