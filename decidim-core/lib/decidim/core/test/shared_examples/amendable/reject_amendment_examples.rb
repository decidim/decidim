# frozen_string_literal: true

shared_examples "reject amendment" do
  before do
    command.call
  end

  it "changes the emendation state to rejected" do
    command.call

    expect(emendation.state).to eq("rejected")
  end

  it "notifies the emendation author and followers" do
    command.call

    expect(Decidim::EventsManager)
      .to receive(:publish)
  end
end
