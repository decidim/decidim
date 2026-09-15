# frozen_string_literal: true

shared_examples "a csv token per question votable election" do
  it "allows the user to vote" do
    click_on "Vote"
    expect(page).to have_current_path(new_election_vote_path)
    expect(page).to have_text("Verify your identity")
    fill_in "Email", with: election.voters.first.data["email"]
    fill_in "Token", with: election.voters.first.data["token"]
    click_on "Access"
    expect(page).to have_current_path(election_vote_path(question1))
    expect(page).to have_text(translated_attribute(question1.body))
    expect(page).to have_text(strip_tags(translated_attribute(question1.description)))
    choose translated_attribute(question1.response_options.first.body)
    click_on "Cast vote"
    expect(page).to have_text("Your vote has been successfully cast.")
    expect(page).to have_link("Exit the waiting room")
    question2.update!(voting_enabled_at: Time.current)
    # wait for javascript to update the page
    sleep 2
    expect(page).to have_current_path(election_vote_path(question2))
    expect(page).to have_text(strip_tags(translated_attribute(question2.description)))
    click_on "Cast vote"
    expect(page).to have_text("There was a problem casting your vote.")
    check translated_attribute(question2.response_options.first.body)
    check translated_attribute(question2.response_options.second.body)
    click_on "Cast vote"
    expect(page).to have_current_path(receipt_election_votes_path)
    expect(page).to have_text("Your vote has been successfully cast.")
    click_on "Exit the voting booth"
    expect(page).to have_current_path(election_path)
    expect(page).to have_text("You have already voted.")
    expect(election.votes.where(voter_uid:).size).to eq(3)
    click_on "Edit vote"
    expect(page).to have_current_path(new_election_vote_path)
    fill_in "Email", with: election.voters.first.data["email"]
    fill_in "Token", with: election.voters.first.data["token"]
    click_on "Access"
    click_on "Cast vote"
    uncheck translated_attribute(question2.response_options.first.body)
    click_on "Cast vote"
    expect(page).to have_current_path(receipt_election_votes_path)
    expect(page).to have_text("Your vote has been successfully cast.")
    click_on "Exit the voting booth"
    expect(page).to have_current_path(election_path)
    expect(page).to have_text("You have already voted.")
    expect(election.votes.where(voter_uid:).size).to eq(2)
  end
end

shared_examples "a per question votable election" do
  it "allows the user to vote" do
    expect(page).to have_text(translated_attribute(election.title))
    expect(page).to have_text(translated_attribute(question1.body))
    expect(page).to have_text(translated_attribute(question2.body))
    click_on "Vote"
    expect(page).to have_text(strip_tags(translated_attribute(question1.description)))
    choose translated_attribute(question1.response_options.first.body)
    click_on "Cast vote"
    expect(page).to have_current_path(waiting_election_votes_path)
    expect(page).to have_text("Waiting for the next question")
    expect(page).to have_link("Exit the waiting room")
    question2.update!(voting_enabled_at: Time.current)
    # wait for javascript to update the page
    sleep 2
    expect(page).to have_current_path(election_vote_path(question2))
    expect(page).to have_text(strip_tags(translated_attribute(question2.description)))
    check translated_attribute(question2.response_options.first.body)
    click_on "Cast vote"
    expect(page).to have_current_path(receipt_election_votes_path)
    expect(page).to have_text("Your vote has been successfully cast.")
    click_on "Exit the voting booth"
    expect(page).to have_current_path(election_path)
    expect(page).to have_text("You have already voted.")
    expect(election.votes.where(voter_uid:).size).to eq(2)
    click_on "Edit vote"
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
    expect(page).to have_text("Your vote has been successfully cast.")
    click_on "Exit the voting booth"
    expect(page).to have_current_path(election_path)
    expect(page).to have_text("You have already voted.")
    expect(election.votes.where(voter_uid:).size).to eq(3)
  end
end

shared_examples "a per question votable election with published results" do
  it "allows the user to vote and see published results" do
    expect(page).to have_text(translated_attribute(election.title))
    expect(page).to have_text(translated_attribute(question1.body))
    expect(page).to have_text(translated_attribute(question2.body))
    click_on "Vote"
    expect(page).to have_current_path(waiting_election_votes_path)
    visit election_vote_path(question1)
    expect(page).to have_current_path(waiting_election_votes_path)
    question2.update!(voting_enabled_at: Time.current)
    # wait for javascript to update the page
    sleep 2
    expect(page).to have_current_path(election_vote_path(question2))
    expect(page).to have_text(strip_tags(translated_attribute(question2.description)))
    check translated_attribute(question2.response_options.first.body)
    click_on "Cast vote"
    expect(page).to have_current_path(receipt_election_votes_path)
    expect(page).to have_text("Your vote has been successfully cast.")
    click_on "Exit the voting booth"
    expect(page).to have_current_path(election_path)
    expect(page).to have_text("You have already voted.")
    expect(election.votes.where(voter_uid:).size).to eq(1)
    click_on "Edit vote"
    expect(page).to have_current_path(election_vote_path(question2))
    expect(find("input[value='#{question2.response_options.first.id}']")).to be_checked
    expect(find("input[value='#{question2.response_options.second.id}']")).not_to be_checked
    check translated_attribute(question2.response_options.second.body)
    click_on "Cast vote"
    expect(page).to have_current_path(receipt_election_votes_path)
    expect(page).to have_text("Your vote has been successfully cast.")
    question2.update!(published_results_at: Time.current)
    click_on "Exit the voting booth"
    expect(page).to have_current_path(election_path)
    expect(page).to have_no_text("You have already voted.")
    expect(election.votes.where(voter_uid:).size).to eq(2)
    expect(page).to have_no_link("Vote")
    visit new_election_vote_path
    expect(page).to have_text("You are not authorized to perform this action.")
    visit election_vote_path(question2)
    expect(page).to have_text("You are not authorized to perform this action.")
  end
end

shared_examples "a per question votable election with already voted questions" do
  it "allows the user to vote and see already voted questions" do
    expect(page).to have_text(translated_attribute(election.title))
    expect(page).to have_text(translated_attribute(question1.body))
    expect(page).to have_text(translated_attribute(question2.body))
    expect(page).to have_text(translated_attribute(question3.body))
    click_on "Vote"
    expect(page).to have_text(strip_tags(translated_attribute(question1.description)))
    choose translated_attribute(question1.response_options.first.body)
    click_on "Cast vote"
    check translated_attribute(question2.response_options.first.body)
    click_on "Cast vote"
    expect(page).to have_current_path(waiting_election_votes_path)
    click_on "Edit your vote"
    expect(page).to have_current_path(election_vote_path(question1))
    expect(page).to have_text(strip_tags(translated_attribute(question1.description)))
    expect(find("input[value='#{question1.response_options.first.id}']")).to be_checked
    choose translated_attribute(question1.response_options.second.body)
    click_on "Cast vote"
    expect(page).to have_current_path(election_vote_path(question2))
    expect(page).to have_text(strip_tags(translated_attribute(question2.description)))
    expect(find("input[value='#{question2.response_options.first.id}']")).to be_checked
    expect(find("input[value='#{question2.response_options.second.id}']")).not_to be_checked
    check translated_attribute(question2.response_options.second.body)
    click_on "Cast vote"
    expect(page).to have_current_path(waiting_election_votes_path)
    question1.update!(published_results_at: Time.current)
    click_on "Edit your vote"
    expect(page).to have_current_path(election_vote_path(question2))
    expect(page).to have_text(strip_tags(translated_attribute(question2.description)))
    question2.update!(published_results_at: Time.current)
    click_on "Cast vote"
    expect(page).to have_current_path(waiting_election_votes_path)
    expect(page).to have_no_text("Edit your vote")
  end
end

shared_examples "a per question votable election with automatic redirect when question closes" do
  it "redirects to the waiting room when admin closes voting while user is on question page" do
    expect(page).to have_text(translated_attribute(election.title))
    click_on "Vote"
    expect(page).to have_current_path(election_vote_path(question1))
    expect(page).to have_text(strip_tags(translated_attribute(question1.description)))

    # Simulate admin closing voting for question1 (publishing results)
    question1.update!(published_results_at: Time.current)

    # Wait for JavaScript polling to detect the change and redirect
    expect(page).to have_current_path(waiting_election_votes_path, wait: 3)
    expect(page).to have_text("Waiting for the next question")
  end

  it "redirects to next question when admin closes current question and next is available" do
    # Enable question2 from the start
    question2.update!(voting_enabled_at: Time.current)

    expect(page).to have_text(translated_attribute(election.title))
    click_on "Vote"
    expect(page).to have_current_path(election_vote_path(question1))
    expect(page).to have_text(strip_tags(translated_attribute(question1.description)))

    # Simulate admin closing voting for question1
    question1.update!(published_results_at: Time.current)

    # Wait for JavaScript polling to detect the change and redirect
    expect(page).to have_current_path(election_vote_path(question2), wait: 3)
    expect(page).to have_text(strip_tags(translated_attribute(question2.description)))
  end
end

shared_examples "a per question votable election with edit from receipt" do
  it "allows editing votes from receipt page" do
    click_on "Vote"
    choose translated_attribute(question1.response_options.first.body)
    click_on "Cast vote"
    check translated_attribute(question2.response_options.first.body)
    click_on "Cast vote"
    expect(page).to have_current_path(receipt_election_votes_path)
    expect(page).to have_link("Edit your vote")
    expect(page).to have_link("Exit the voting booth")

    click_on "Edit your vote"
    expect(page).to have_current_path(election_vote_path(question2))
    expect(find("input[value='#{question2.response_options.first.id}']")).to be_checked

    click_on "Back"
    expect(page).to have_current_path(election_vote_path(question1))
    expect(find("input[value='#{question1.response_options.first.id}']")).to be_checked

    choose translated_attribute(question1.response_options.second.body)
    click_on "Cast vote"
    expect(page).to have_current_path(election_vote_path(question2))

    check translated_attribute(question2.response_options.second.body)
    click_on "Cast vote"
    expect(page).to have_current_path(receipt_election_votes_path)
    expect(election.votes.where(voter_uid:).size).to eq(3)

    click_on "Exit the voting booth"
    expect(page).to have_current_path(election_path)
    expect(page).to have_text("You have already voted.")
  end
end

shared_examples "a per question votable election with edit from receipt when all questions enabled" do
  it "allows editing any question from receipt page" do
    click_on "Vote"
    choose translated_attribute(question1.response_options.first.body)
    click_on "Cast vote"
    check translated_attribute(question2.response_options.first.body)
    click_on "Cast vote"
    expect(page).to have_current_path(receipt_election_votes_path)

    click_on "Edit your vote"
    expect(page).to have_current_path(election_vote_path(question2))

    click_on "Back"
    expect(page).to have_current_path(election_vote_path(question1))

    choose translated_attribute(question1.response_options.second.body)
    click_on "Cast vote"
    expect(page).to have_current_path(election_vote_path(question2))
    expect(find("input[value='#{question2.response_options.first.id}']")).to be_checked

    click_on "Cast vote"
    expect(page).to have_current_path(receipt_election_votes_path)

    click_on "Edit your vote"
    click_on "Back"
    choose translated_attribute(question1.response_options.first.body)
    click_on "Cast vote"
    uncheck translated_attribute(question2.response_options.first.body)
    check translated_attribute(question2.response_options.second.body)
    click_on "Cast vote"
    expect(page).to have_current_path(receipt_election_votes_path)
    expect(election.votes.where(voter_uid:).size).to eq(2)
  end
end
