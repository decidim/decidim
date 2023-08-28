# frozen_string_literal: true

require "spec_helper"

shared_examples "manage accountability attachments" do
  let(:attached_to) { result }
  let(:attachment_collection) { create(:attachment_collection, collection_for: result) }

  before do
    within find("tr", text: translated(result.title)) do
      click_link "Attachments"
    end
  end

  it_behaves_like "manage attachments examples"
end
