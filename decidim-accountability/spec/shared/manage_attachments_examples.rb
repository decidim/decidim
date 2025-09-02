# frozen_string_literal: true

require "spec_helper"

shared_examples "manage accountability attachments" do
  let(:attached_to) { result }
  let(:attachment_collection) { create(:attachment_collection, collection_for: result) }

  before do
    within "tr", text: translated(result.title) do
      find("button[data-controller='dropdown']").click
      click_on "Add attachment"
    end
  end

  it_behaves_like "manage attachments examples"
end
