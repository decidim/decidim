# frozen_string_literal: true

shared_examples "manage accountability attachment collections" do
  let(:collection_for) { result }

  before do
    within find("tr", text: translated(result.title)) do
      click_link "Folders"
    end
  end

  it_behaves_like "manage attachment collections examples"
end
