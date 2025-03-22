# frozen_string_literal: true

require "spec_helper"

describe "Participatory Process Groups" do
  let(:organization) { create(:organization) }
  let(:other_organization) { create(:organization) }
  let!(:participatory_process_group) do
    create(
      :participatory_process_group,
      :with_participatory_processes,
      organization:,
      title: { en: "Title", ca: "Títol", es: "Título" },
      hashtag: "my_awesome_hashtag",
      group_url: "https://www.example.org/external"
    )
  end
  let(:group_processes) { participatory_process_group.participatory_processes }
  let(:process) { group_processes.first }
  let(:other_process) { group_processes.last }
  let(:out_of_group_process) { create(:participatory_process, :active, organization:) }
  let(:hero_settings) do
    {
      button_url_en: "https://example.org/action",
      button_text_en: "hero text"
    }
  end

  before do
    switch_to_host(organization.host)
  end

  context "when there are some groups" do
    let!(:other_group) { create(:participatory_process_group, organization: other_organization) }

    before do
      visit decidim_participatory_processes.participatory_processes_path(locale: I18n.locale)
    end

    it "lists all the groups among the processes" do
      within "#processes-grid" do
        expect(page).to have_content(translated(participatory_process_group.title, locale: :en))
        expect(page).to have_css("a.card__grid", count: 1)

        expect(page).to have_no_content(translated(other_group.title, locale: :en))
      end
    end

    it "links to the individual group page" do
      first("a.card__grid h3", text: translated(participatory_process_group.title, locale: :en)).click

      expect(page).to have_current_path decidim_participatory_processes.participatory_process_group_path(participatory_process_group, locale: I18n.locale)
    end
  end

  context "when the group does not exist" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_participatory_processes.participatory_process_group_path(99_999_999, locale: I18n.locale) }
    end
  end

  context "when the group exists" do
    it_behaves_like "editable content for admins" do
      let(:target_path) { decidim_participatory_processes.participatory_process_group_path(participatory_process_group, locale: I18n.locale) }
    end
  end

  describe "show" do
    context "when the title_content block is enabled" do
      before do
        create(
          :content_block,
          organization:,
          scope_name: :participatory_process_group_homepage,
          scoped_resource_id: participatory_process_group.id,
          manifest_name: :title
        )
        visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group, locale: I18n.locale)
      end

      it "shows the title" do
        expect(page).to have_content("Title")
      end

      it "shows the processes count" do
        expect(page).to have_content("2 processes")
      end

      it "shows the description" do
        expect(page).to have_i18n_content(participatory_process_group.description, strip_tags: true)
      end

      it "shows the meta scope name" do
        expect(page).to have_i18n_content(participatory_process_group.meta_scope)
      end

      it "shows the hashtag" do
        expect(page).to have_content("#my_awesome_hashtag")
      end

      it "has a link to the group url" do
        expect(page).to have_link("www.example.org/external", href: "https://www.example.org/external")
      end

      it_behaves_like "has embedded video in description", :description do
        before do
          participatory_process_group.update!(description:)
          visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group, locale: I18n.locale)
        end
      end
    end

    context "when the metadata content block is enabled" do
      before do
        create(
          :content_block,
          organization:,
          scope_name: :participatory_process_group_homepage,
          scoped_resource_id: participatory_process_group.id,
          manifest_name: :extra_data
        )
        visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group, locale: I18n.locale)
      end

      it "shows metadata attributes" do
        within "#participatory_process_group-extra_data" do
          expect(page).to have_i18n_content(participatory_process_group.developer_group, strip_tags: true)
          expect(page).to have_i18n_content(participatory_process_group.target, strip_tags: true)
          expect(page).to have_i18n_content(participatory_process_group.participatory_scope, strip_tags: true)
          expect(page).to have_i18n_content(participatory_process_group.participatory_structure, strip_tags: true)
        end
      end
    end

    context "when the hero content block is enabled" do
      before do
        create(
          :content_block,
          organization:,
          scope_name: :participatory_process_group_homepage,
          scoped_resource_id: participatory_process_group.id,
          manifest_name: :hero,
          settings: hero_settings
        )
        visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group, locale: I18n.locale)
      end

      it "shows the action button" do
        within("[data-process-hero]") do
          expect(page).to have_link(hero_settings[:button_text_en], href: hero_settings[:button_url_en])
        end
      end

      context "when url is not configured" do
        let(:hero_settings) { nil }

        it "shows the block" do
          expect(page).to have_css("[data-process-hero]")
        end
      end

      it_behaves_like "accessible page"
    end

    context "when the proposals block is enabled" do
      let!(:proposals_component) { create(:component, :published, participatory_space: process, manifest_name: :proposals) }
      let!(:other_process_proposals_component) { create(:component, :published, participatory_space: other_process, manifest_name: :proposals) }
      let!(:out_of_group_process_proposals_component) { create(:component, :published, participatory_space: out_of_group_process, manifest_name: :proposals) }
      let!(:proposal1) { create(:proposal, component: proposals_component, title: { en: "First awesome proposal!" }) }
      let!(:proposal2) { create(:proposal, component: other_process_proposals_component, title: { en: "Second fabulous proposal!" }) }
      let!(:independent_proposal) { create(:proposal, component: out_of_group_process_proposals_component, title: { en: "Independent proposal!" }) }

      before do
        create(
          :content_block,
          organization:,
          scope_name: :participatory_process_group_homepage,
          scoped_resource_id: participatory_process_group.id,
          manifest_name: :highlighted_proposals
        )

        visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group, locale: I18n.locale)
      end

      it "shows cards of proposals from both processes" do
        within("#participatory-process-group-homepage-highlighted-proposals") do
          expect(page).to have_css("#proposals__proposal_#{proposal1.id}")
          expect(page).to have_css("#proposals__proposal_#{proposal2.id}")

          within("#proposals__proposal_#{proposal1.id}") do
            expect(page).to have_content "First awesome proposal!"
            expect(page).to have_i18n_content(process.title, strip_tags: true)
          end

          within("#proposals__proposal_#{proposal2.id}") do
            expect(page).to have_content "Second fabulous proposal!"
            expect(page).to have_i18n_content(other_process.title, strip_tags: true)
          end
        end
      end

      it "does not show cards of proposals from process out of group" do
        expect(page).to have_no_selector("#proposals__proposal_#{independent_proposal.id}")
        expect(page).to have_no_content "Independent proposal!"
        expect(page).not_to have_i18n_content(out_of_group_process.title, strip_tags: true)
      end
    end

    context "when the results block is enabled" do
      let!(:accountability_component) { create(:component, :published, participatory_space: process, manifest_name: :accountability) }
      let!(:other_process_accountability_component) { create(:component, :published, participatory_space: other_process, manifest_name: :accountability) }
      let!(:out_of_group_process_accountability_component) { create(:component, :published, participatory_space: out_of_group_process, manifest_name: :accountability) }
      let!(:result1) { create(:result, component: accountability_component, title: { en: "First awesome result!" }) }
      let!(:result2) { create(:result, component: other_process_accountability_component, title: { en: "Second fabulous result!" }) }
      let!(:independent_result) { create(:result, component: out_of_group_process_accountability_component, title: { en: "Independent result!" }) }

      before do
        create(
          :content_block,
          organization:,
          scope_name: :participatory_process_group_homepage,
          scoped_resource_id: participatory_process_group.id,
          manifest_name: :highlighted_results
        )

        visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group, locale: I18n.locale)
      end

      it "shows cards of results from both processes" do
        within("#participatory-process-group-homepage-highlighted-results") do
          expect(page).to have_css("#accountability__result_#{result1.id}")
          expect(page).to have_css("#accountability__result_#{result2.id}")

          within("#accountability__result_#{result1.id}") do
            expect(page).to have_content "First awesome result!"
            expect(page).to have_i18n_content(process.title, strip_tags: true)
          end

          within("#accountability__result_#{result2.id}") do
            expect(page).to have_content "Second fabulous result!"
            expect(page).to have_i18n_content(other_process.title, strip_tags: true)
          end
        end
      end

      it "does not show cards of results from process out of group" do
        expect(page).to have_no_selector("#accountability__result_#{independent_result.id}")
        expect(page).to have_no_content "Independent result!"
        expect(page).not_to have_i18n_content out_of_group_process.title
      end
    end

    context "when the html block is enabled" do
      before do
        # rubocop:disable Naming/VariableNumber
        create(
          :content_block,
          organization:,
          scope_name: :participatory_process_group_homepage,
          scoped_resource_id: participatory_process_group.id,
          manifest_name: :html_1,
          settings: {
            html_content_ca: nil,
            html_content_en: "<div id=\"testing-html\">HTML block</div>",
            html_content_es: nil
          }
        )
        # rubocop:enable Naming/VariableNumber

        visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group, locale: I18n.locale)
      end

      it "renders the content of content block" do
        expect(page).to have_css("#testing-html")
        within("#testing-html") do
          expect(page).to have_content("HTML block")
        end
      end
    end
  end

  context "when the meetings block is enabled" do
    let!(:meetings_component) { create(:component, :published, participatory_space: process, manifest_name: :meetings) }
    let!(:other_process_meetings_component) { create(:component, :published, participatory_space: other_process, manifest_name: :meetings) }
    let!(:out_of_group_process_meetings_component) { create(:component, :published, participatory_space: out_of_group_process, manifest_name: :meetings) }
    let!(:meeting1) { create(:meeting, :published, component: meetings_component, title: { en: "First awesome meeting!" }) }
    let!(:meeting2) { create(:meeting, :published, component: other_process_meetings_component, title: { en: "Second fabulous meeting!" }) }
    let!(:independent_meeting) { create(:meeting, :published, component: out_of_group_process_meetings_component, title: { en: "Independent meeting!" }) }

    before do
      create(
        :content_block,
        organization:,
        scope_name: :participatory_process_group_homepage,
        scoped_resource_id: participatory_process_group.id,
        manifest_name: :highlighted_meetings
      )

      visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group, locale: I18n.locale)
    end

    it "shows cards of meetings from both processes" do
      within("#participatory-process-group-homepage-highlighted-meetings") do
        expect(page).to have_content "UPCOMING MEETINGS"
        expect(page).to have_content "First awesome meeting!"
        expect(page).to have_content "Second fabulous meeting!"
      end
    end

    it "does not show cards of meetings from process out of group" do
      expect(page).to have_no_content "Independent meeting!"
    end
  end

  context "when the stats content block is enabled" do
    before do
      create(
        :content_block,
        organization:,
        scope_name: :participatory_process_group_homepage,
        scoped_resource_id: participatory_process_group.id,
        manifest_name: :stats
      )
    end

    it "shows no statistics content block if there are no components or followers in depending participatory processes" do
      visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group, locale: I18n.locale)

      expect(page).to have_no_css("section[data-statistics]")
    end

    context "when there are components and depending resources" do
      let(:process) { participatory_process_group.participatory_processes.first }
      let(:other_process) { participatory_process_group.participatory_processes.last }
      let!(:proposals_component) { create(:component, :published, participatory_space: process, manifest_name: :proposals) }
      let!(:other_process_proposals_component) { create(:component, :published, participatory_space: other_process, manifest_name: :proposals) }
      let!(:other_process_meetings_component) { create(:component, :published, participatory_space: other_process, manifest_name: :meetings) }
      let!(:user) { create(:user, organization:) }
      let!(:out_of_group_process_proposals_component) { create(:component, :published, participatory_space: out_of_group_process, manifest_name: :proposals) }
      let!(:out_of_group_process_meetings_component) { create(:component, :published, participatory_space: out_of_group_process, manifest_name: :meetings) }

      before do
        create_list(:proposal, 3, component: proposals_component)
        create_list(:proposal, 7, component: other_process_proposals_component)
        create_list(:meeting, 4, :published, component: other_process_meetings_component)
        create_list(:proposal, 50, component: out_of_group_process_proposals_component)
        create_list(:meeting, 50, component: out_of_group_process_meetings_component)

        # Set same coauthorships for all proposals
        Decidim::Proposals::Proposal.where(component: [proposals_component, other_process_proposals_component]).each do |proposal|
          proposal.coauthorships.clear
          proposal.coauthorships.create(author: user)
        end
        visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group, locale: I18n.locale)
      end

      it "shows the statistics content block" do
        expect(page).to have_css("section[data-statistics]")
      end

      it "shows unique participants count from both participatory processes" do
        within("[data-statistic][class*=participants]") do
          expect(page).to have_css(".statistic__title", text: "Participants")
          expect(page).to have_css(".statistic__number", text: "1")
        end
      end

      it "shows accumulated resources from components of both participatory processes" do
        within("[data-statistic][class*=proposals]") do
          expect(page).to have_css(".statistic__title", text: "Proposals")
          expect(page).to have_css(".statistic__number", text: "10")
        end

        within("[data-statistic][class*=meetings]") do
          expect(page).to have_css(".statistic__title", text: "Meetings")
          expect(page).to have_css(".statistic__number", text: "4")
        end
      end
    end
  end

  context "when participatory processes block is enabled" do
    let!(:scope) { create(:scope, organization:) }
    let!(:area) { create(:area, organization:) }
    let!(:participatory_process_group) do
      create(
        :participatory_process_group,
        organization:
      )
    end
    let(:participatory_processes_content_block_settings) { nil }
    let!(:past_process_with_scope) do
      create(
        :participatory_process,
        :published,
        :past,
        scope:,
        organization:,
        participatory_process_group:,
        weight: 4
      )
    end
    let!(:active_process) do
      create(
        :participatory_process,
        :published,
        :active,
        start_date: 1.year.ago,
        organization:,
        participatory_process_group:,
        weight: 5
      )
    end
    let!(:active_process_with_scope) do
      create(
        :participatory_process,
        :published,
        :active,
        start_date: 1.month.ago,
        scope:,
        organization:,
        participatory_process_group:,
        weight: 6
      )
    end
    let!(:active_process_with_area) do
      create(
        :participatory_process,
        :published,
        :active,
        start_date: 1.week.ago,
        area:,
        organization:,
        participatory_process_group:,
        weight: 3
      )
    end
    let!(:upcoming_process_with_area) do
      create(
        :participatory_process,
        :published,
        :upcoming,
        area:,
        organization:,
        participatory_process_group:,
        weight: 2
      )
    end
    let!(:other_group_process) do
      create(
        :participatory_process,
        :published,
        :active,
        scope:,
        area:,
        organization:,
        participatory_process_group: create(:participatory_process_group, organization:),
        weight: 1
      )
    end
    let(:titles) { page.all("a.card__grid h3") }

    shared_examples "showing all processes counts" do
      it "shows count of all group processes" do
        within "#processes-grid h3" do
          expect(page).to have_content(/ALL\s+\(5\)/)
        end
      end
    end

    shared_examples "not showing processes belonging to other group" do
      it "does not list process of other group" do
        within("#processes-grid") do
          expect(page).to have_no_content(translated(other_group_process.title, locale: :en))
        end
      end
    end

    before do
      create(
        :content_block,
        organization:,
        scope_name: :participatory_process_group_homepage,
        scoped_resource_id: participatory_process_group.id,
        manifest_name: :participatory_processes,
        settings: participatory_processes_content_block_settings
      )
      visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group, locale: I18n.locale)
    end

    shared_examples "shows active processes" do
      it "lists active processes ordered by weight" do
        within "section.content-block" do
          expect(titles[0].text).to eq(translated(active_process_with_area.title, locale: :en))
          expect(titles[1].text).to eq(translated(active_process.title, locale: :en))
          expect(titles[2].text).to eq(translated(active_process_with_scope.title, locale: :en))
        end
      end

      it "does not list process of other group" do
        within "section.content-block" do
          expect(page).to have_no_content(translated(other_group_process.title, locale: :en))
        end
      end

      it "does not list inactive processes" do
        within "section.content-block" do
          expect(page).to have_no_content(translated(upcoming_process_with_area.title, locale: :en))
          expect(page).to have_no_content(translated(past_process_with_scope.title, locale: :en))
        end
      end

      it "shows count of active processes" do
        within "div.content-block__title" do
          expect(page).to have_content("Active participatory processes")
          expect(page).to have_content("3")
        end
      end
    end

    context "when the block filter settings is blank" do
      it_behaves_like "shows active processes"
    end

    context "when the block filter settings configures active processes" do
      let(:participatory_processes_content_block_settings) { { default_filter: "active" } }

      it_behaves_like "shows active processes"
    end

    context "when the block filter settings configures all processes" do
      let(:participatory_processes_content_block_settings) { { default_filter: "all" } }

      it "lists all processes ordered by weight" do
        within "section.content-block" do
          expect(titles[0].text).to eq(translated(upcoming_process_with_area.title, locale: :en))
          expect(titles[1].text).to eq(translated(active_process_with_area.title, locale: :en))
          expect(titles[2].text).to eq(translated(past_process_with_scope.title, locale: :en))
          expect(titles[3].text).to eq(translated(active_process.title, locale: :en))
          expect(titles[4].text).to eq(translated(active_process_with_scope.title, locale: :en))
        end
      end

      it "does not list process of other group" do
        within "section.content-block" do
          expect(page).to have_no_content(translated(other_group_process.title, locale: :en))
        end
      end

      it "shows count of all processes" do
        within "div.content-block__title" do
          expect(page).to have_content("Participatory processes")
          expect(page).to have_no_content("Active")
          expect(page).to have_content("5")
        end
      end
    end
  end
end
