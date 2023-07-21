# frozen_string_literal: true

require "spec_helper"

describe "show", type: :system do
  include_context "with a component"
  let(:manifest_name) { "debates" }

  let(:description) { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_debate_title } }
  let(:information_updates) { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_debate_title } }
  let(:instructions) { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_debate_title } }
  let!(:debate) { create(:debate, component:, description:, information_updates:, instructions:) }

  before do
    visit_component
    click_link debate.title[I18n.locale.to_s], class: "card__list"
  end

  context "when is created from the admin panel" do
    let!(:debate) { create(:debate, :official, component:, description:, information_updates:, instructions:) }

    context "when the field is decription" do
      it_behaves_like "has embedded video in description", :description
    end

    context "when the field is information_updates" do
      it_behaves_like "has embedded video in description", :information_updates
    end

    context "when the field is instructions" do
      it_behaves_like "has embedded video in description", :instructions
    end
  end

  context "when is created by the participant" do
    let!(:debate) { create(:debate, :participant_author, component:, description:, information_updates:, instructions:) }
    let(:iframe_src) { "http://www.example.org" }

    context "when the field is decription" do
      let(:description) { { en: %(Description <iframe class="ql-video" allowfullscreen="true" src="#{iframe_src}" frameborder="0"></iframe>) } }

      it { expect(page).not_to have_selector("iframe") }
    end

    context "when the field is information_updates" do
      let(:information_updates) { { en: %(Description <iframe class="ql-video" allowfullscreen="true" src="#{iframe_src}" frameborder="0"></iframe>) } }

      it { expect(page).not_to have_selector("iframe") }
    end

    context "when the field is instructions" do
      let(:instructions) { { en: %(Description <iframe class="ql-video" allowfullscreen="true" src="#{iframe_src}" frameborder="0"></iframe>) } }

      it { expect(page).not_to have_selector("iframe") }
    end
  end

  context "when shows the debate component" do
    it "shows the debate title" do
      expect(page).to have_content debate.title[I18n.locale.to_s]
    end
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
