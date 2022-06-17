# frozen_string_literal: true

require "spec_helper"

describe "Explore debates", type: :system do
  include_context "with a component"
  let(:manifest_name) { "debates" }

  before do
    switch_to_host(organization.host)
    component_scope = create :scope, parent: participatory_process.scope
    component_settings = component["settings"]["global"].merge!(scopes_enabled: true, scope_id: component_scope.id)
    component.update!(settings: component_settings)
  end

  describe "index" do
    let(:debates_count) { 5 }
    let!(:debates) do
      create_list(
        :debate,
        debates_count,
        component:,
        start_time: Time.zone.local(2016, 12, 13, 14, 15),
        end_time: Time.zone.local(2016, 12, 13, 16, 17),
        skip_injection: true
      )
    end

    it "lists all debates for the given process" do
      visit_component

      expect(page).to have_selector(".card--debate", count: debates_count)

      debates.each do |debate|
        expect(page).to have_content(translated(debate.title))
      end
    end

    context "when there are a lot of debates" do
      let!(:debates) do
        create_list(:debate, Decidim::Paginable::OPTIONS.first + 5, component:, skip_injection: true)
      end

      it "paginates them" do
        visit_component

        expect(page).to have_css(".card--debate", count: Decidim::Paginable::OPTIONS.first)

        click_link "Next"

        expect(page).to have_selector(".pagination .current", text: "2")

        expect(page).to have_css(".card--debate", count: 5)
      end
    end

    context "when there are open debates" do
      let!(:open_debate) do
        create(
          :debate,
          component:,
          start_time: nil,
          end_time: nil,
          skip_injection: true
        )
      end

      it "the card informs that they are open" do
        visit_component
        within "#debate_#{open_debate.id}" do
          expect(page).to have_content "OPEN DEBATE"
        end
      end
    end

    context "when there's an announcement set" do
      let(:announcement) do
        { en: "Important announcement" }
      end

      context "with the component's settings" do
        before do
          component.update!(settings: { announcement: })
          visit_component
        end

        it "shows the announcement" do
          expect(page).to have_content("Important announcement")
        end
      end

      context "with the step's settings" do
        before do
          component.update!(
            step_settings: {
              component.participatory_space.active_step.id => {
                announcement:
              }
            }
          )
          visit_component
        end

        it "shows the announcement" do
          expect(page).to have_content("Important announcement")
        end
      end
    end

    context "when filtering" do
      context "when filtering by origin" do
        context "with 'official' origin" do
          let!(:debates) { create_list(:debate, 2, component:, skip_injection: true) }

          it "lists the filtered debates" do
            create(:debate, :participant_author, component:, skip_injection: true)
            visit_component

            within ".filters .with_any_origin_check_boxes_tree_filter" do
              uncheck "All"
              check "Official"
            end

            expect(page).to have_css(".card--debate", count: 2)
            expect(page).to have_content("2 DEBATES")
          end
        end

        context "with 'participants' origin" do
          let!(:debates) { create_list(:debate, 2, :participant_author, component:, skip_injection: true) }

          it "lists the filtered debates" do
            create(:debate, component:, skip_injection: true)
            visit_component

            within ".filters .with_any_origin_check_boxes_tree_filter" do
              uncheck "All"
              check "Participants"
            end

            expect(page).to have_css(".card--debate", count: 2)
            expect(page).to have_content("2 DEBATES")
          end
        end
      end

      it "allows filtering by scope" do
        scope = create(:scope, organization:)
        debate = debates.first
        debate.scope = scope
        debate.save

        visit_component

        within ".with_any_scope_check_boxes_tree_filter" do
          check "All"
          uncheck "All"
          check translated(scope.name)
        end

        expect(page).to have_css(".card--debate", count: 1)
      end

      context "when filtering by category" do
        let(:category2) { create :category, participatory_space: }
        let(:debates) { create_list(:debate, 3, component:, category: category2, skip_injection: true) }

        before do
          create(:debate, component:, category:, skip_injection: true)
          login_as user, scope: :user
          visit_component
        end

        it "can be filtered by category" do
          within ".filters .with_any_category_check_boxes_tree_filter" do
            uncheck "All"
            check category.name[I18n.locale.to_s]
          end

          expect(page).to have_css(".card--debate", count: 1)
        end

        it "works with 'back to list' link" do
          within ".filters .with_any_category_check_boxes_tree_filter" do
            uncheck "All"
            check category.name[I18n.locale.to_s]
          end

          expect(page).to have_css(".card--debate", count: 1)

          page.find(".card--debate .card__link").click

          click_link "Back to list"

          expect(page).to have_css(".card--debate", count: 1)
        end
      end
    end

    context "with hidden debates" do
      let(:debate) { debates.last }

      before do
        create :moderation, :hidden, reportable: debate
        visit_component
      end

      it "does not list the hidden debates" do
        expect(page).to have_selector(".card--debate", count: debates_count - 1)
        expect(page).to have_no_content(translated(debate.title))
      end
    end

    context "with comment metadata" do
      let!(:comment) { create(:comment, commentable: debates) }
      let!(:debates) { create(:debate, :open_ama, component:, skip_injection: true) }

      it "shows the last comment author and the time" do
        visit_component

        within ".card__footer" do
          expect(page).to have_content("Commented")
        end
      end
    end
  end

  context "when component is not commentable" do
    let(:component) { create :debante_component, :with_comments_blocked, participatory_space: }
    let(:resources) { create_list(:debate, 3, component:) }

    it_behaves_like "an uncommentable component"
  end

  describe "show" do
    let(:path) do
      decidim_participatory_process_debates.debate_path(
        id: debate.id,
        participatory_process_slug: participatory_space.slug,
        component_id: component.id
      )
    end
    let!(:debate) do
      create(
        :debate,
        :open_ama,
        component:,
        start_time: Time.zone.local(2016, 12, 13, 14, 15),
        end_time: Time.zone.local(2016, 12, 13, 16, 17),
        skip_injection: true
      )
    end

    before do
      visit path
    end

    it "shows all debate info" do
      expect(page).to have_i18n_content(debate.title)
      expect(page).to have_i18n_content(debate.description, strip_tags: true)
      expect(page).to have_i18n_content(debate.information_updates, strip_tags: true)
      expect(page).to have_i18n_content(debate.instructions, strip_tags: true)

      within ".section.view-side" do
        expect(page).to have_content(13)
        expect(page).to have_content(/December/i)
        expect(page).to have_content("14:15 - 16:17")
      end
    end

    context "without category or scope" do
      it "does not show any tag" do
        expect(page).not_to have_selector("ul.tags.tags--debate")
      end
    end

    context "with a category" do
      let(:debate) do
        debate = create(:debate, component:, skip_injection: true)
        debate.category = create :category, participatory_space: participatory_space
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

    context "with a scope" do
      let(:debate) do
        debate = create(:debate, component:, skip_injection: true)
        debate.scope = create(:scope, organization:)
        debate.save
        debate
      end

      it "shows tags for scope" do
        expect(page).to have_selector("ul.tags.tags--debate")
        within "ul.tags.tags--debate" do
          expect(page).to have_content(translated(debate.scope.name))
        end
      end

      it "links to the filter for this scope" do
        within "ul.tags.tags--debate" do
          click_link translated(debate.scope.name)
        end

        within ".filters" do
          expect(page).to have_checked_field(translated(debate.scope.name))
        end
      end
    end

    context "when debate is official" do
      let!(:debate) { create(:debate, author: organization, description: { en: content }, component:, skip_injection: true) }

      it_behaves_like "rendering safe content", ".columns.mediumlarge-8.mediumlarge-pull-4"
    end

    context "when rich text editor is enabled for participants" do
      let!(:debate) { create(:debate, author: user, description: { en: content }, component:, skip_injection: true) }

      before do
        organization.update(rich_text_editor_in_public_views: true)
        visit path
      end

      it_behaves_like "rendering safe content", ".columns.mediumlarge-8.mediumlarge-pull-4"
    end

    context "when rich text editor is NOT enabled on the frontend" do
      let!(:debate) { create(:debate, author: user, description: { en: content }, component:, skip_injection: true) }

      it_behaves_like "rendering unsafe content", ".columns.mediumlarge-8.mediumlarge-pull-4"
    end
  end
end
