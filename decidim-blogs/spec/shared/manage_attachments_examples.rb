# frozen_string_literal: true

require "spec_helper"

shared_examples "manage posts attachments" do
  let(:attached_to) { post }
  let(:attachment_collection) { create(:attachment_collection, collection_for: post) }

  before do
    within "tr", text: translated(post.title) do
      find("button[data-component='dropdown']").click
      click_on "Attachments"
    end
  end

  it_behaves_like "manage attachments examples"
end
