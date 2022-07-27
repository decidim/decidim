# frozen_string_literal: true

require "spec_helper"

describe "show", type: :system do
  include_context "with a component"
  let(:manifest_name) { "debates" }

  let!(:debate) { create(:debate, component:, skip_injection: true) }

  before do
    visit_component
    click_link debate.title[I18n.locale.to_s], class: "card__link"
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
        within ".definition-data" do
          expect(page).to have_content("No comments yet")
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

      it "shows the last comment author" do
        within ".definition-data" do
          expect(page).to have_content(last_comment.author.name)
        end
      end

      it "shows the last comment author when it's a user group" do
        group = create(:user_group, organization: debate.organization)
        create(:comment, commentable: debate, author: group)

        visit current_url

        within ".definition-data" do
          expect(page).to have_content(group.name)
        end
      end

      it "shows the number of participants" do
        within ".definition-data" do
          expect(page).to have_content("PARTICIPANTS\n1")
          expect(page).to have_content("GROUPS\n1")
        end
      end
    end
  end
end
