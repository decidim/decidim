# frozen_string_literal: true

require "decidim/admin/test/manage_attachment_collections_examples"

shared_examples "manage meetings attachment collections" do
  let(:collection_for) { meeting }

  before do
    within find("tr", text: translated(meeting.title)) do
      click_link "Collections"
    end
  end

  it_behaves_like "manage attachment collections examples"
end
