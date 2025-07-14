# frozen_string_literal: true

require "spec_helper"

shared_examples "manage project attachments" do
  let(:attached_to) { project }
  let(:attachment_collection) { create(:attachment_collection, collection_for: project) }

  before do
    within "tr", text: translated(budget.title) do
      find("button[data-component='dropdown']").click
      click_on "Manage projects"
    end

    within "tr", text: translated(project.title) do
      find("button[data-component='dropdown']").click
      click_on "Attachments"
    end
  end

  it_behaves_like "manage attachments examples"
end
