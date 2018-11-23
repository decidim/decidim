# frozen_string_literal: true

shared_examples "reject amendment" do
  before do
    command.call
  end

  it "changes the emendation state to rejected" do
    expect(emendation.state).to eq("rejected")
  end
end
