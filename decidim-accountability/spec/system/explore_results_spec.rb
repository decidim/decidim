# frozen_string_literal: true

require "spec_helper"

describe "Explore results", :versioning do
  include_context "with a component"

  let(:manifest_name) { "accountability" }
  let(:path) { decidim_participatory_process_accountability.root_path(participatory_process_slug: participatory_process.slug, component_id: component.id, locale: I18n.locale) }
  let(:taxonomy) { create(:taxonomy, :with_parent, skip_injection: true, organization:) }
  let(:sub_taxonomy) { create(:taxonomy, parent: taxonomy, organization:) }
  let!(:other_taxonomy) { create(:taxonomy, parent: taxonomy.parent, organization:) }
  let(:other_sub_taxonomy) { create(:taxonomy, parent: other_taxonomy, organization:) }
  let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy: taxonomy.parent) }
  let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }
  let!(:sub_taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: sub_taxonomy) }
  let(:taxonomy_filter_ids) { [taxonomy_filter.id] }

  before do
    component.update!(settings: { taxonomy_filters: taxonomy_filter_ids })
  end

  context "when there are no results" do
    before do
      visit path
    end

    context "without any taxonomy" do
      let(:taxonomy_filter_ids) { [] }

      it "shows an empty page with a message" do
        expect(page).to have_content "There are no projects"
      end
    end

    context "with a taxonomy" do
      it "shows an empty page with a message" do
        within "main" do
          expect(page).to have_content "There are no projects"
        end
      end
    end
  end

  context "when there are results" do
    let(:results_count) { 5 }
    let(:address) { "Carrer de Sant Joan, 123, 08001 Barcelona" }
    let(:latitude) { 41.38879 }
    let(:longitude) { 2.15899 }
    let!(:results) do
      create_list(
        :result,
        results_count,
        component:
      )
    end

    describe "home" do
      before do
        # Add taxonomies for the results to test they work correctly
        results[0..2].each { |r| r.update!(taxonomies: [sub_taxonomy]) }
        results[3..-1].each { |r| r.update!(taxonomies: [other_sub_taxonomy]) }

        # Add address to one result to see if it works correctly
        results.first.update!(address:, latitude:, longitude:)

        # Enable geocoding in the component
        component.update!(settings: { taxonomy_filters: taxonomy_filter_ids, geocoding_enabled: true })

        # Mock Decidim::Map.available?(:geocoding, :dynamic) to return true
        allow(Decidim::Map).to receive(:available?).with(:geocoding, :dynamic).and_return(true)

        # Revisit the path to load updated results
        visit path
      end

      it "shows the component name in the sidebar" do
        within("aside") do
          expect(page).to have_content(translated(component.name))
        end
      end

      it "shows the map" do
        expect(page).to have_css(".accountability__map")
      end

      it "shows root taxonomies filters" do
        within("aside") do
          expect(page).to have_content(translated(taxonomy.parent.name))
        end
      end

      it "shows progress" do
        expect(page).to have_content("Global execution status")
        within("aside") do
          expect(page).to have_css(".accountability__status-value")
        end
      end

      context "with progress disabled" do
        before do
          component.update!(settings: { display_progress_enabled: false, taxonomy_filters: taxonomy_filter_ids })
        end

        it "does not show progress" do
          visit path

          expect(page).to have_no_content("Global execution status")
          within("aside") do
            expect(page).to have_no_css(".accountability__status-value")
          end
        end
      end

      context "when searching" do
        let!(:matching_result1) do
          create(
            :result,
            title: Decidim::Faker::Localized.literal("A doggo in the title"),
            component:
          )
        end
        let!(:matching_result2) do
          create(
            :result,
            title: Decidim::Faker::Localized.literal("Other matching result"),
            description: Decidim::Faker::Localized.literal("There is a doggo in the office"),
            component:
          )
        end

        it "displays the correct search results" do
          fill_in :filter_search_text_cont, with: "doggo"
          within "form .filter-search" do
            find("*[type=submit]").click
          end

          within("#results") do
            expect(page).to have_content(translated(matching_result1.title))
            expect(page).to have_content(translated(matching_result2.title))

            results.each do |result|
              expect(page).to have_no_content(translated(result.title))
            end
          end
        end
      end
    end

    describe "index" do
      let(:path) { decidim_participatory_process_accountability.results_path(participatory_process_slug: participatory_process.slug, component_id: component.id, locale: I18n.locale) }

      before do
        visit path
      end

      it "shows all results for the given process and taxonomy" do
        within("#results") do
          expect(page).to have_css(".card__list", count: results_count)

          results.each do |result|
            expect(page).to have_content(translated(result.title))
          end
        end
      end
    end

    describe "show" do
      let(:path) { decidim_participatory_process_accountability.result_path(id: result.id, participatory_process_slug: participatory_process.slug, component_id: component.id, locale: I18n.locale) }
      let(:results_count) { 1 }
      let(:result) { results.first }

      before do
        visit path
      end

      it "shows all result info" do
        expect(page).to have_i18n_content(result.title)
        expect(page).to have_i18n_content(result.description, strip_tags: true)
        expect(page).to have_content(result.reference)
        expect(page).to have_content("#{result.progress.to_i}%")
      end

      context "when it has no versions" do
        before do
          result.versions.destroy_all
          visit current_path
        end

        it "does not show version data" do
          expect(page).to have_no_content("Version number")
        end
      end

      context "when it has some versions" do
        it "does shows version data" do
          expect(page).to have_content("Version number 1")
        end
      end

      context "with a taxonomy" do
        let(:result) do
          result = results.first
          result.taxonomies << taxonomy
          result.save
          result
        end

        it "shows tags for taxonomy" do
          expect(page).to have_css("[data-tags]")
          within "[data-tags]" do
            expect(page).to have_content(translated(taxonomy.name))
          end
        end
      end

      context "when a result has comments" do
        let(:result) { results.first }
        let(:author) { create(:user, :confirmed, organization: component.organization) }
        let!(:comments) { create_list(:comment, 3, commentable: result) }

        before do
          visit current_path
        end

        it "shows the comments" do
          comments.each do |comment|
            expect(page).to have_content(comment.body.values.first)
          end
        end
      end

      context "with timeline entries" do
        let!(:timeline_entries) { create_list(:timeline_entry, 3, result:) }
        let(:timeline_entry) { timeline_entries.first }

        before do
          visit current_path
        end

        it "shows the tab" do
          expect(page).to have_content("Project evolution")
        end

        it "shows the timeline entry" do
          expect(page).to have_content(decidim_sanitize_translated(timeline_entry.title))
          expect(page).to have_content(I18n.l(timeline_entry.entry_date, format: :decidim_short))
          expect(page).to have_content(decidim_sanitize_translated(timeline_entry.description))
        end
      end

      context "with subresults" do
        let!(:subresults) { create_list(:result, 3, component:, parent: result) }
        let(:first_subresult) { subresults.first }

        before do
          visit current_path
        end

        it "shows the tab" do
          expect(page).to have_content("Subresults")
        end

        it "shows subresults" do
          subresults.each do |subresult|
            expect(page).to have_content(translated(subresult.title))
          end
        end

        it "the result is mentioned in the subresult page" do
          click_on translated(first_subresult.title)
          expect(page).to have_i18n_content(result.title)
        end

        it "a banner links back to the result" do
          click_on translated(first_subresult.title)
          expect(page).to have_content(translated(result.title))
        end
      end

      context "with linked proposals" do
        let(:proposal_component) do
          create(:component, manifest_name: :proposals, participatory_space: result.component.participatory_space)
        end
        let(:proposals) { create_list(:proposal, 3, component: proposal_component) }
        let(:proposal) { proposals.first }

        before do
          result.link_resources(proposals, "included_proposals")
          visit current_path
        end

        it "shows the tab" do
          expect(page).to have_content("History")
        end

        it "shows related proposals" do
          proposals.each do |proposal|
            expect(page).to have_content(decidim_sanitize_translated(proposal.title))
            expect(page).to have_no_content(proposal.creator_author.name)
            expect(page).to have_content(proposal.votes.size)
          end
        end

        it "the result is mentioned in the proposal page" do
          click_on decidim_sanitize_translated(proposal.title)

          expect(page).to have_i18n_content(decidim_sanitize_translated(result.title))
        end

        it "a banner links back to the result" do
          click_on decidim_sanitize_translated(proposal.title)

          expect(page).to have_content(decidim_sanitize_translated(result.title))
        end
      end

      context "with linked projects" do
        let(:budgets_component) do
          create(:component, manifest_name: :budgets, participatory_space: result.component.participatory_space)
        end
        let(:budget) { create(:budget, component: budgets_component) }
        let(:projects) { create_list(:project, 3, budget:) }
        let(:project) { projects.first }

        before do
          result.link_resources(projects, "included_projects")
          visit current_path
        end

        it "shows the tab" do
          expect(page).to have_content("History")
        end

        it "shows related projects" do
          projects.each do |project|
            expect(page).to have_content(decidim_sanitize_translated(project.title))
          end
        end

        it "the result is mentioned in the project page" do
          click_on decidim_sanitize_translated(project.title)
          expect(page).to have_i18n_content(decidim_sanitize_translated(result.title))
        end
      end

      context "with linked meetings" do
        let(:meeting_component) do
          create(:component, manifest_name: :meetings, participatory_space: result.component.participatory_space)
        end
        let(:meetings) { create_list(:meeting, 3, :published, component: meeting_component) }
        let(:meeting) { meetings.first }

        before do
          stub_geocoding_coordinates([meeting.latitude, meeting.longitude])
          result.link_resources(meetings, "meetings_through_proposals")
          visit current_path
        end

        it "shows the tab" do
          expect(page).to have_content("History")
        end

        it "shows related meetings" do
          meetings.each do |meeting|
            expect(page).to have_i18n_content(decidim_sanitize_translated(meeting.title))
          end
        end

        it "the result is mentioned in the meeting page" do
          click_on decidim_sanitize_translated(meeting.title)
          expect(page).to have_i18n_content(translated(result.title))
        end

        it "a banner links back to the result" do
          click_on decidim_sanitize_translated(meeting.title)
          expect(page).to have_content(translated(result.title))
        end
      end

      it_behaves_like "has attachments tabs" do
        let(:attached_to) { result }
      end
    end
  end
end

def select_tab(text)
  find("li", text:).click
end
