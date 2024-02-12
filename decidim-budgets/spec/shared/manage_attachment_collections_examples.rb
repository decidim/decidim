# frozen_string_literal: true

shared_examples "manage projects attachment collections" do
  let(:collection_for) { project }

  before do
    within "tr", text: translated(budget.title) do
      click_on "Manage projects"
    end

    within "tr", text: translated(project.title) do
      click_on "Folders"
    end
  end

  it_behaves_like "manage attachment collections examples"
end
