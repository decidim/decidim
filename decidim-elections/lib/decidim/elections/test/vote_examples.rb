# frozen_string_literal: true

shared_examples "shows questions in an election" do
  it "shows all the questions" do
    expect(page).to have_content(translated_attribute(election.title))

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
end

shared_examples "a votable election" do
  it_behaves_like "shows questions in an election"

  it "allows the user to vote" do
    click_on "Start voting"

    fill_in_votes
    click_on "Start voting"
    expect(page).to have_current_path(election_vote_path(election.questions.first))
    expect(election.votes.pluck(:voter_uid)).to include(voter_uid)
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
end
