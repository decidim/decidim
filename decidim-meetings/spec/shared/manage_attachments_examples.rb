# frozen_string_literal: true

require "decidim/admin/test/manage_attachments_examples"

shared_examples "manage meetings attachments" do
  let(:attached_to) { meeting }

  before do
    within find("tr", text: translated(meeting.title)) do
      click_link "Attachments"
    end
  end

  it_behaves_like "manage attachments examples"
end
