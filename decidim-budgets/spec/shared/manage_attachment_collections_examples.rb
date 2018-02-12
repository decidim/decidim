# frozen_string_literal: true

shared_examples "manage projects attachment collections" do
  let(:collection_for) { project }

  before do
    within find("tr", text: translated(project.title)) do
      click_link "Collections"
    end
  end

  it_behaves_like "manage attachment collections examples"
end
