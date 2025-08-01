# frozen_string_literal: true

shared_examples "a csv token per question votable election" do
  it "allows the user to vote" do
    click_on "Vote"
    expect(page).to have_current_path(new_election_vote_path)
    expect(page).to have_content("Verify your identity")
    fill_in "Email", with: election.voters.first.data["email"]
    fill_in "Token", with: election.voters.first.data["token"]
    click_on "Access"
    expect(page).to have_current_path(election_vote_path(question1))
    expect(page).to have_content(translated_attribute(question1.body))
    choose translated_attribute(question1.response_options.first.body)
    click_on "Cast vote"
    expect(page).to have_content("Your vote has been successfully cast.")
    expect(page).to have_link("Exit the waiting room")
    question2.update!(voting_enabled_at: Time.current)
    # wait for javascript to update the page
    sleep 2
    expect(page).to have_current_path(election_vote_path(question2))
    click_on "Cast vote"
    expect(page).to have_content("There was a problem casting your vote.")
    check translated_attribute(question2.response_options.first.body)
    check translated_attribute(question2.response_options.second.body)
    click_on "Cast vote"
    expect(page).to have_current_path(receipt_election_votes_path)
    expect(page).to have_content("Your vote has been successfully cast.")
    click_on "Exit the voting booth"
    expect(page).to have_current_path(election_path)
    expect(page).to have_content("You have already voted.")
    expect(election.votes.where(voter_uid:).size).to eq(3)
    click_on "Vote"
    expect(page).to have_current_path(new_election_vote_path)
    fill_in "Email", with: election.voters.first.data["email"]
    fill_in "Token", with: election.voters.first.data["token"]
    click_on "Access"
    click_on "Cast vote"
    uncheck translated_attribute(question2.response_options.first.body)
    click_on "Cast vote"
    expect(page).to have_current_path(receipt_election_votes_path)
    expect(page).to have_content("Your vote has been successfully cast.")
    click_on "Exit the voting booth"
    expect(page).to have_current_path(election_path)
    expect(page).to have_content("You have already voted.")
    expect(election.votes.where(voter_uid:).size).to eq(2)
  end
end

shared_examples "a per question votable election" do
  it "allows the user to vote" do
    expect(page).to have_content(translated_attribute(election.title))
    expect(page).to have_content(translated_attribute(question1.body))
    expect(page).to have_content(translated_attribute(question2.body))
    click_on "Vote"
    choose translated_attribute(question1.response_options.first.body)
    click_on "Cast vote"
    expect(page).to have_current_path(waiting_election_votes_path)
    expect(page).to have_content("Waiting for the next question")
    expect(page).to have_link("Exit the waiting room")
    question2.update!(voting_enabled_at: Time.current)
    # wait for javascript to update the page
    sleep 2
    expect(page).to have_current_path(election_vote_path(question2))
    check translated_attribute(question2.response_options.first.body)
    click_on "Cast vote"
    expect(page).to have_current_path(receipt_election_votes_path)
    expect(page).to have_content("Your vote has been successfully cast.")
    click_on "Exit the voting booth"
    expect(page).to have_current_path(election_path)
    expect(page).to have_content("You have already voted.")
    expect(election.votes.where(voter_uid:).size).to eq(2)
    click_on "Vote"
    expect(find("input[value='#{question1.response_options.first.id}']")).to be_checked
    choose translated_attribute(question1.response_options.second.body)
    click_on "Cast vote"
    expect(find("input[value='#{question2.response_options.first.id}']")).to be_checked
    click_on "Back"
    expect(find("input[value='#{question1.response_options.second.id}']")).to be_checked
    click_on "Cast vote"
    check translated_attribute(question2.response_options.second.body)
    click_on "Cast vote"
    expect(page).to have_current_path(receipt_election_votes_path)
    expect(page).to have_content("Your vote has been successfully cast.")
    click_on "Exit the voting booth"
    expect(page).to have_current_path(election_path)
    expect(page).to have_content("You have already voted.")
    expect(election.votes.where(voter_uid:).size).to eq(3)
  end
end

shared_examples "a per question votable election with published results" do
  it "allows the user to vote and see published results" do
    expect(page).to have_content(translated_attribute(election.title))
    expect(page).to have_content(translated_attribute(question1.body))
    expect(page).to have_content(translated_attribute(question2.body))
    click_on "Vote"
    expect(page).to have_current_path(waiting_election_votes_path)
    visit election_vote_path(question1)
    expect(page).to have_current_path(waiting_election_votes_path)
    question2.update!(voting_enabled_at: Time.current)
    # wait for javascript to update the page
    sleep 2
    expect(page).to have_current_path(election_vote_path(question2))
    check translated_attribute(question2.response_options.first.body)
    click_on "Cast vote"
    expect(page).to have_current_path(receipt_election_votes_path)
    expect(page).to have_content("Your vote has been successfully cast.")
    click_on "Exit the voting booth"
    expect(page).to have_current_path(election_path)
    expect(page).to have_content("You have already voted.")
    expect(election.votes.where(voter_uid:).size).to eq(1)
    click_on "Vote"
    expect(page).to have_current_path(election_vote_path(question2))
    expect(find("input[value='#{question2.response_options.first.id}']")).to be_checked
    expect(find("input[value='#{question2.response_options.second.id}']")).not_to be_checked
    check translated_attribute(question2.response_options.second.body)
    click_on "Cast vote"
    expect(page).to have_current_path(receipt_election_votes_path)
    expect(page).to have_content("Your vote has been successfully cast.")
    question2.update!(published_results_at: Time.current)
    click_on "Exit the voting booth"
    expect(page).to have_current_path(election_path)
    expect(page).to have_no_content("You have already voted.")
    expect(election.votes.where(voter_uid:).size).to eq(2)
    expect(page).to have_no_link("Vote")
    visit new_election_vote_path
    expect(page).to have_content("You are not authorized to perform this action.")
    visit election_vote_path(question2)
    expect(page).to have_content("You are not authorized to perform this action.")
  end
end

shared_examples "a per question votable election with already voted questions" do
  it "allows the user to vote and see already voted questions" do
    expect(page).to have_content(translated_attribute(election.title))
    expect(page).to have_content(translated_attribute(question1.body))
    expect(page).to have_content(translated_attribute(question2.body))
    expect(page).to have_content(translated_attribute(question3.body))
    click_on "Vote"
    choose translated_attribute(question1.response_options.first.body)
    click_on "Cast vote"
    check translated_attribute(question2.response_options.first.body)
    click_on "Cast vote"
    expect(page).to have_current_path(waiting_election_votes_path)
    click_on "Edit your vote"
    expect(page).to have_current_path(election_vote_path(question1))
    expect(find("input[value='#{question1.response_options.first.id}']")).to be_checked
    choose translated_attribute(question1.response_options.second.body)
    click_on "Cast vote"
    expect(page).to have_current_path(election_vote_path(question2))
    expect(find("input[value='#{question2.response_options.first.id}']")).to be_checked
    expect(find("input[value='#{question2.response_options.second.id}']")).not_to be_checked
    check translated_attribute(question2.response_options.second.body)
    click_on "Cast vote"
    expect(page).to have_current_path(waiting_election_votes_path)
    question1.update!(published_results_at: Time.current)
    click_on "Edit your vote"
    expect(page).to have_current_path(election_vote_path(question2))
    question2.update!(published_results_at: Time.current)
    click_on "Cast vote"
    expect(page).to have_current_path(waiting_election_votes_path)
    expect(page).to have_no_content("Edit your vote")
  end
end
