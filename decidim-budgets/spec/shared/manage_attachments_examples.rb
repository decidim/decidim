# frozen_string_literal: true

require "spec_helper"

shared_examples "manage project attachments" do
  let(:attached_to) { project }
  let(:attachment_collection) { create(:attachment_collection, collection_for: project) }

  before do
    within find("tr", text: translated(budget.title)) do
      click_link "Manage projects"
    end

    within find("tr", text: translated(project.title)) do
      click_link "Attachments"
    end
  end

  it_behaves_like "manage attachments examples"
end
