# frozen_string_literal: true

shared_examples "manage posts attachment collections" do
  let(:collection_for) { post }

  before do
    within find("tr", text: translated(post.title)) do
      click_link "Folders"
    end
  end

  it_behaves_like "manage attachment collections examples"
end
