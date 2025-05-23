# frozen_string_literal: true

require "spec_helper"

describe "User closes a debate" do
  include_context "with a component"

  let(:manifest_name) { "debates" }
  let!(:debate) do
    create(
      :debate,
      author: user,
      component:
    )
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component
    click_on debate.title.values.first
  end

  context "when closing my debate" do
    let!(:like) do
      5.times do
        create(:like, resource: debate, author: build(:user, organization: debate.participatory_space.organization))
      end
    end

    it "allows closing my debate", :slow do
      find("#dropdown-trigger-resource-#{debate.id}").click
      find("button[data-dialog-open='close-debate']", text: "Close").click

      within ".close-debate-modal" do
        fill_in :debate_conclusions, with: "Yes, all organizations should use Decidim!"
        click_on "Close debate"
      end

      expect(page).to have_content("The debate was closed")
      expect(page).to have_content("Yes, all organizations should use Decidim!")
      expect(page).to have_css(".likes-list__avatar")
    end
  end

  context "when the debate has been closed" do
    let!(:debate) do
      create(
        :debate,
        :closed,
        author: user,
        component:
      )
    end

    it "cannot be edited" do
      expect(page).to have_no_content("Edit debate")
    end

    it "is allowed to change the conclusions" do
      find("#dropdown-trigger-resource-#{debate.id}").click
      click_on "Edit conclusions"

      within ".close-debate-modal" do
        fill_in :debate_conclusions, with: "New conclusions"
        click_on "Close debate"
      end

      expect(page).to have_content("New conclusions")
    end
  end
end
