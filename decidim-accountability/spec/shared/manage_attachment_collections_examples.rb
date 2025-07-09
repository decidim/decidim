# frozen_string_literal: true

shared_examples "manage accountability attachment collections" do
  let(:collection_for) { result }

  before do
    within "tr", text: translated(result.title) do
      find("button[data-component='dropdown']").click
      click_on "Folders"
    end
  end

  it_behaves_like "manage attachment collections examples"
end
