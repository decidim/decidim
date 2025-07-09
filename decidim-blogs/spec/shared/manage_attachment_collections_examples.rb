# frozen_string_literal: true

shared_examples "manage posts attachment collections" do
  let(:collection_for) { post }

  before do
    within "tr", text: translated(post.title) do
      find("button[data-component='dropdown']").click
      click_on "Folders"
    end
  end

  it_behaves_like "manage attachment collections examples"
end
