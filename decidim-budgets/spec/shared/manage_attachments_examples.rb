# frozen_string_literal: true

require "decidim/admin/test/manage_attachments_examples"

shared_examples "manage project attachments" do
  let(:attached_to) { project }

  before do
    within find("tr", text: translated(project.title)) do
      click_link "Attachments"
    end
  end

  it_behaves_like "manage attachments examples"
end
