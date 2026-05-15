# frozen_string_literal: true

shared_examples_for "a download your data entity" do
  let(:data) { subject.send(:readme) }

  before do
    subject.send(:data_and_attachments_for_user) # to create the data and get the help definitions
  end

  it "does not have any missing translation" do
    expect(data).not_to include("Translation missing"), data
  end

  it "has the correct help definition" do
    expect(data).to include(help_definition_string)
  end
end
