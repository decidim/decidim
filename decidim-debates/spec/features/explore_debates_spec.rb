# frozen_string_literal: true

require "spec_helper"

describe "Explore debates", type: :feature do
  include_context "with a feature"
  let(:manifest_name) { "debates" }

  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization: organization) }
  let(:current_feature) { create :feature, participatory_space: participatory_process, manifest_name: "debates" }
  let(:debates_count) { 5 }
  let!(:debates) do
    create_list(
      :debate,
      debates_count,
      feature: current_feature,
      start_time: Time.zone.local(2016, 12, 13, 14, 15),
      end_time: Time.zone.local(2016, 12, 13, 16, 17)
    )
  end

  before do
    switch_to_host(organization.host)
  end

  describe "index" do
    let(:path) { decidim_participatory_process_debates.debates_path(participatory_process_slug: participatory_process.slug, feature_id: current_feature.id) }

    it "shows all debates for the given process" do
      visit path

      expect(page).to have_selector("article.card", count: debates_count)

      debates.each do |debate|
        expect(page).to have_content(translated(debate.title))
      end
    end
  end

  describe "show" do
    let(:path) do
      decidim_participatory_process_debates.debate_path(
        id: debate.id,
        participatory_process_slug: participatory_process.slug,
        feature_id: current_feature.id
      )
    end
    let(:debates_count) { 1 }
    let(:debate) { debates.first }

    before do
      visit path
    end

    it "shows all debate info" do
      expect(page).to have_i18n_content(debate.title)
      expect(page).to have_i18n_content(debate.description)
      expect(page).to have_i18n_content(debate.information_updates)
      expect(page).to have_i18n_content(debate.instructions)

      within ".section.view-side" do
        expect(page).to have_content(13)
        expect(page).to have_content(/December/i)
        expect(page).to have_content("14:15 - 16:17")
      end
    end

    context "without category" do
      it "does not show any tag" do
        expect(page).not_to have_selector("ul.tags.tags--debate")
      end
    end

    context "with a category" do
      let(:debate) do
        debate = debates.first
        debate.category = create :category, participatory_space: participatory_process
        debate.save
        debate
      end

      it "shows tags for category" do
        expect(page).to have_selector("ul.tags.tags--debate")

        within "ul.tags.tags--debate" do
          expect(page).to have_content(translated(debate.category.name))
        end
      end
    end
  end

  context "when creating a new debate" do
    let(:user) { create :user, :confirmed, organization: organization }
    let!(:category) { create :category, participatory_space: participatory_space }

    context "when the user is logged in" do
      before do
        login_as user, scope: :user
      end

      context "with creation enabled" do
        it "creates a new debate", :slow do
          visit_feature

          click_link "New debate"

          within ".new_debate" do
            fill_in :debate_title, with: "Should Oriol be president?"
            fill_in :debate_description, with: "Would he solve everything?"
            fill_in :debate_instructions, with: "Please behave"
            select translated(category.name), from: :debate_category_id

            find("*[type=submit]").click
          end

          expect(page).to have_content("successfully")
          expect(page).to have_content("Should Oriol be president?")
          expect(page).to have_content("Would he solve everything?")
          expect(page).to have_content("Please behave")
          expect(page).to have_content(translated(category.name))
          expect(page).to have_selector(".author-data", text: user.name)
        end

        context "when the user isn't authorized" do
          before do
            permissions = {
              create: {
                authorization_handler_name: "dummy_authorization_handler"
              }
            }

            feature.update_attributes!(permissions: permissions)
          end

          it "shows a modal dialog" do
            visit_feature
            click_link "New debate"
            expect(page).to have_content("Authorization required")
          end
        end
      end
    end
  end
end
