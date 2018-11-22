# frozen_string_literal: true

shared_examples "accept amendment" do
  before do
    command.call
  end

  it "changes the emendation state to accepted" do
    command.call

    expect(emendation.state).to eq("accepted")
  end

  it "adds the emendation author as coauthor of the proposal" do
    command.call

    expect(amendable.coauthorships.count).to eq(2)
    expect(amendable.authored_by?(emendation.creator_author)).to eq(true)
  end
end
