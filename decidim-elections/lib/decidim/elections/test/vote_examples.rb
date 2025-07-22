# frozen_string_literal: true

shared_examples "shows questions in an election" do
  it "shows all the questions" do
    expect(page).to have_content(translated_attribute(election.title))

    within ".questions-list" do
      election.questions.each do |question|
        expect(page).to have_content(translated_attribute(question.body))
        question.response_options.each do |option|
          expect(page).to have_no_content(translated_attribute(option.body))
        end
        click_on translated_attribute(question.body)
        question.response_options.each do |option|
          expect(page).to have_content(translated_attribute(option.body))
        end
      end
    end
  end
end

def fill_in_votes
  expect(page).to have_current_path(election_vote_path(election.questions.first))
  expect(page).to have_content(translated_attribute(election.questions.first.body))
  check translated_attribute(election.questions.first.response_options.first.body)
  click_on "Next"
  expect(page).to have_current_path(election_vote_path(election.questions.second))
  expect(page).to have_content(translated_attribute(election.questions.second.body))
  check translated_attribute(election.questions.second.response_options.second.body)
  click_on "Next"
  expect(page).to have_current_path(confirm_election_votes_path)
  expect(page).to have_content("Confirm your vote")
  expect(page).to have_content(translated_attribute(election.questions.first.body))
  expect(page).to have_content(translated_attribute(election.questions.first.response_options.first.body))
  expect(page).to have_no_content(translated_attribute(election.questions.first.response_options.second.body))
  expect(page).to have_content(translated_attribute(election.questions.second.body))
  expect(page).to have_no_content(translated_attribute(election.questions.second.response_options.first.body))
  expect(page).to have_content(translated_attribute(election.questions.second.response_options.second.body))
  click_on "Cast vote"
  expect(page).to have_content("Your vote has been successfully cast.")
  click_on "Exit the voting booth"
  expect(page).to have_current_path(election_path)
  expect(page).to have_content("You have already voted.")
  expect(election.votes.pluck(:voter_uid)).to include(voter_uid)
end

def fill_in_question_votes(question)
  expect(page).to have_current_path(election_vote_path(question))
  expect(page).to have_content(translated_attribute(question.body))
  check translated_attribute(question.response_options.first.body)
  click_on "Cast vote"
end

shared_examples "a votable election" do
  it "allows the user to vote" do
    click_on "Start voting"

    fill_in_votes
    click_on "Start voting"
    expect(page).to have_current_path(election_vote_path(election.questions.first))
  end
end

shared_examples "an internal users authentication voter form" do
  it "allows the user to log in" do
    expect(page).to have_current_path(election_path)
    click_on "Start voting"
    expect(page).to have_current_path(new_election_vote_path)
    expect(page).to have_content("Verify your identity")
    expect(page).to have_button("Log in")
    expect(page).to have_link("Create an account")
    click_on "Log in"
    fill_in "Email", with: user.email
    fill_in "Password", with: "decidim123456789"
    click_on "Log in"
    fill_in_votes
  end

  it "allows the user to create an account" do
    expect(page).to have_current_path(election_path)
    click_on "Start voting"
    expect(page).to have_current_path(new_election_vote_path)
    expect(page).to have_content("Verify your identity")
    expect(page).to have_button("Log in")
    expect(page).to have_link("Create an account")
    click_on "Create an account"
    within "#register-form" do
      fill_in "Your name", with: "John Doe"
      fill_in "Your email", with: "john@example.org"
      fill_in "Password", with: "decidim123456789"
      check "By signing up you agree to the terms of service."
      check "Receive an occasional newsletter with relevant information"
      click_on "Create an account"
    end
    expect(page).to have_content("A message with a confirmation link has been sent to your email address.")
  end
end

shared_examples "an internal users verification voter form" do
  it "allows the user to verify their identity" do
    expect(page).to have_current_path(election_path)
    click_on "Start voting"
    expect(page).to have_current_path(new_election_vote_path)
    expect(page).to have_content("Verify your identity")
    click_on "Verify with Example authorization"
    fill_in "Document number", with: "12345678X"
    fill_in "Postal code", with: "08002"
    click_on "Send"
    fill_in_votes
  end

  it "denies voting if the user does not fulfills the authorization requirements" do
    expect(page).to have_current_path(election_path)
    click_on "Start voting"
    expect(page).to have_current_path(new_election_vote_path)
    expect(page).to have_content("Verify your identity")
    click_on "Verify with Example authorization"
    fill_in "Document number", with: "12345678X"
    fill_in "Postal code", with: "08003"
    click_on "Send"
    expect(page).to have_content("You are not authorized to vote in this election.")
  end
end

shared_examples "a csv token votable election" do
  it "allows the user to vote" do
    click_on "Start voting"
    expect(page).to have_current_path(new_election_vote_path)
    expect(page).to have_content("Verify your identity")
    fill_in "Email", with: "bob@example.org"
    fill_in "Token", with: "123456"
    click_on "Access"
    expect(page).to have_content("The email or token is not valid.")
    fill_in "Email", with: election.voters.first.data["email"]
    fill_in "Token", with: election.voters.first.data["token"]
    click_on "Access"
    fill_in_votes
    click_on "Start voting"
    expect(page).to have_current_path(new_election_vote_path)
  end
end

shared_examples "a per question votable election" do
  it "allows the user to vote" do
    expect(page).to have_content(translated_attribute(election.title))
    expect(page).to have_content(translated_attribute(question1.body))
    expect(page).to have_content(translated_attribute(question2.body))
    click_on "Start voting"
    fill_in_question_votes(question1)
    expect(page).to have_current_path(waiting_election_votes_path)
    expect(page).to have_content("Waiting for the next question")
    expect(page).to have_link("Exit the waiting room")
    question2.update!(voting_enabled_at: Time.current)
    # wait for javascript to update the page
    sleep 2
    expect(page).to have_current_path(election_vote_path(question2))
    fill_in_question_votes(question2)
    expect(page).to have_current_path(receipt_election_votes_path)
    expect(page).to have_content("Your vote has been successfully cast.")
    click_on "Exit the voting booth"
    expect(page).to have_current_path(election_path)
    expect(page).to have_content("You have already voted.")
    expect(election.votes.pluck(:voter_uid)).to include(voter_uid)
  end
end
