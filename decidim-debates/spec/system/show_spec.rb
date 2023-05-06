# frozen_string_literal: true

require "spec_helper"

describe "show", type: :system do
  include_context "with a component"
  let(:manifest_name) { "debates" }

  let(:description) { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_debate_title } }
  let(:information_updates) { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_debate_title } }
  let(:instructions) { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_debate_title } }
  let!(:debate) { create(:debate, component: component, description: description, information_updates: information_updates, instructions: instructions, skip_injection: true) }

  before do
    visit_component
    click_link debate.title[I18n.locale.to_s], class: "card__link"
  end

  context "when is created from the admin panel" do
    let!(:debate) { create(:debate, :official, component: component, description: description, information_updates: information_updates, instructions: instructions) }

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
    let!(:debate) { create(:debate, :citizen_author, component: component, description: description, information_updates: information_updates, instructions: instructions) }
    let(:iframe_src) { "http://www.example.org" }

    context "when the field is decription" do
      let(:description) { { en: %(Description <iframe class="ql-video" allowfullscreen="true" src="#{iframe_src}" frameborder="0"></iframe>) } }

      it { expect(page).not_to have_selector("iframe") }
    end

    context "when the field is information_updates" do
      let(:information_updates) { { en: %(Description <iframe class="ql-video" allowfullscreen="true" src="#{iframe_src}" frameborder="0"></iframe>) } }

      it { expect(page).to have_selector("iframe") }
    end

    context "when the field is instructions" do
      let(:instructions) { { en: %(Description <iframe class="ql-video" allowfullscreen="true" src="#{iframe_src}" frameborder="0"></iframe>) } }

      it { expect(page).to have_selector("iframe") }
    end
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
