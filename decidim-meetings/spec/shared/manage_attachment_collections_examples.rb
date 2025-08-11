# frozen_string_literal: true

shared_examples "manage meetings attachment collections" do
  let(:collection_for) { meeting }

  before do
    within "tr", text: translated(meeting.title) do
      find("button[data-controller='dropdown']").click
      click_on "Add folder"
    end
  end

  it_behaves_like "manage attachment collections examples"
end
