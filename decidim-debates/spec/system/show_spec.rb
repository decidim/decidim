# frozen_string_literal: true

require "spec_helper"

describe "show", type: :system do
  include_context "with a component"
  let(:manifest_name) { "debates" }

  let!(:debate) { create(:debate, component:, skip_injection: true) }

  before do
    visit_component
    click_link debate.title[I18n.locale.to_s], class: "card__list"
  end

  context "when shows the debate component" do
    it "shows the debate title" do
      expect(page).to have_content debate.title[I18n.locale.to_s]
    end

    it_behaves_like "going back to list button"
  end

  describe "comments metadata" do
    context "when there are no comments" do
      it "shows default values" do
        within "#comments" do
          expect(page).to have_content("0 comments")
        end
      end
    end

    context "when there are some comments" do
      let(:last_comment) { Decidim::Comments::Comment.last }

      before do
        group = create(:user_group, organization: debate.organization)
        create(:comment, commentable: debate, author: group)
        create(:comment, commentable: debate)

        visit current_url
      end

      it "shows the number of participants" do
        skip_unless_redesign_enabled "This content appears with redesign fully enabled"

        within ".layout-item__aside" do
          expect(page).to have_content("Participants\n1")
          expect(page).to have_content("Groups\n1")
        end
      end
    end
  end
end
