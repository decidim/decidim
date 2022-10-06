# frozen_string_literal: true

require "spec_helper"

describe "Participatory Process Groups", type: :system do
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
  let(:cta_settings) do
    {
      button_url: "https://example.org/action",
      button_text_en: "cta text",
      description_en: "cta description"
    }
  end

  before do
    switch_to_host(organization.host)
  end

  context "when there are some groups" do
    let!(:other_group) { create(:participatory_process_group, organization: other_organization) }

    before do
      visit decidim_participatory_processes.participatory_processes_path
    end

    it "lists all the groups among the processes" do
      within "#processes-grid" do
        expect(page).to have_content(translated(participatory_process_group.title, locale: :en))
        expect(page).to have_selector(".card", count: 1)

        expect(page).to have_no_content(translated(other_group.title, locale: :en))
      end
    end

    it "links to the individual group page" do
      first(".card__link", text: translated(participatory_process_group.title, locale: :en)).click

      expect(page).to have_current_path decidim_participatory_processes.participatory_process_group_path(participatory_process_group)
    end
  end

  context "when the group does not exist" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_participatory_processes.participatory_process_group_path(99_999_999) }
    end
  end

  context "when the group exists" do
    it_behaves_like "editable content for admins" do
      let(:target_path) { decidim_participatory_processes.participatory_process_group_path(participatory_process_group) }
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
        visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group)
      end

      it "shows the title" do
        expect(page).to have_content("Title")
      end

      it "shows the description" do
        expect(page).to have_i18n_content(participatory_process_group.description)
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
    end

    context "when the metadata content block is enabled" do
      before do
        create(
          :content_block,
          organization:,
          scope_name: :participatory_process_group_homepage,
          scoped_resource_id: participatory_process_group.id,
          manifest_name: :metadata
        )
        visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group)
      end

      it "shows metadata attributes" do
        within "#participatory_process_group-metadata" do
          expect(page).to have_i18n_content(participatory_process_group.developer_group)
          expect(page).to have_i18n_content(participatory_process_group.target)
          expect(page).to have_i18n_content(participatory_process_group.participatory_scope)
          expect(page).to have_i18n_content(participatory_process_group.participatory_structure)
        end
      end
    end

    context "when the cta content block is enabled" do
      before do
        create(
          :content_block,
          organization:,
          scope_name: :participatory_process_group_homepage,
          scoped_resource_id: participatory_process_group.id,
          manifest_name: :cta,
          settings: cta_settings
        )
        visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group)
      end

      it "shows the description" do
        within("div.hero__container") do
          expect(page).to have_content(cta_settings[:description_en])
        end
      end

      it "Shows the action button" do
        within("div.hero__container") do
          expect(page).to have_link(cta_settings[:button_text_en], href: cta_settings[:button_url])
        end
      end

      context "when url is not configured" do
        let(:cta_settings) { nil }

        it "doesn't show the block" do
          expect(page).to have_no_selector("div.hero__container")
        end
      end
    end

    context "when the proposals block is enabled" do
      let!(:proposals_component) { create(:component, :published, participatory_space: process, manifest_name: :proposals) }
      let!(:other_process_proposals_component) { create(:component, :published, participatory_space: other_process, manifest_name: :proposals) }
      let!(:proposal1) { create(:proposal, component: proposals_component, title: { en: "First awesome proposal!" }) }
      let!(:proposal2) { create(:proposal, component: other_process_proposals_component, title: { en: "Second fabulous proposal!" }) }

      before do
        create(
          :content_block,
          organization:,
          scope_name: :participatory_process_group_homepage,
          scoped_resource_id: participatory_process_group.id,
          manifest_name: :highlighted_proposals
        )

        visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group)
      end

      it "shows cards of proposals from both processes" do
        within("#participatory-process-group-homepage-highlighted-proposals") do
          expect(page).to have_selector("#proposal_#{proposal1.id}")
          expect(page).to have_selector("#proposal_#{proposal2.id}")

          within("#proposal_#{proposal1.id}") do
            expect(page).to have_content "First awesome proposal!"
            expect(page).to have_i18n_content process.title
          end

          within("#proposal_#{proposal2.id}") do
            expect(page).to have_content "Second fabulous proposal!"
            expect(page).to have_i18n_content other_process.title
          end
        end
      end
    end

    context "when the results block is enabled" do
      let!(:accountability_component) { create(:component, :published, participatory_space: process, manifest_name: :accountability) }
      let!(:other_process_accountability_component) { create(:component, :published, participatory_space: other_process, manifest_name: :accountability) }
      let!(:result1) { create(:result, component: accountability_component, title: { en: "First awesome result!" }) }
      let!(:result2) { create(:result, component: other_process_accountability_component, title: { en: "Second fabulous result!" }) }

      before do
        create(
          :content_block,
          organization:,
          scope_name: :participatory_process_group_homepage,
          scoped_resource_id: participatory_process_group.id,
          manifest_name: :highlighted_results
        )

        visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group)
      end

      it "shows cards of results from both processes" do
        within("#participatory-process-group-homepage-highlighted-results") do
          expect(page).to have_selector("#result_#{result1.id}")
          expect(page).to have_selector("#result_#{result2.id}")

          within("#result_#{result1.id}") do
            expect(page).to have_content "First awesome result!"
            expect(page).to have_i18n_content process.title
          end

          within("#result_#{result2.id}") do
            expect(page).to have_content "Second fabulous result!"
            expect(page).to have_i18n_content other_process.title
          end
        end
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

        visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group)
      end

      it "renders the content of content block" do
        expect(page).to have_selector("#testing-html")
        within("#testing-html") do
          expect(page).to have_content("HTML block")
        end
      end
    end
  end

  context "when the meetings block is enabled" do
    let!(:meetings_component) { create(:component, :published, participatory_space: process, manifest_name: :meetings) }
    let!(:other_process_meetings_component) { create(:component, :published, participatory_space: other_process, manifest_name: :meetings) }
    let!(:meeting1) { create(:meeting, :published, component: meetings_component, title: { en: "First awesome meeting!" }) }
    let!(:meeting2) { create(:meeting, :published, component: other_process_meetings_component, title: { en: "Second fabulous meeting!" }) }

    before do
      create(
        :content_block,
        organization:,
        scope_name: :participatory_process_group_homepage,
        scoped_resource_id: participatory_process_group.id,
        manifest_name: :highlighted_meetings
      )

      visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group)
    end

    it "shows cards of meetings from both processes" do
      within("#participatory-process-group-homepage-highlighted-meetings") do
        expect(page).to have_content "UPCOMING MEETINGS"
        expect(page).to have_content "First awesome meeting!"
        expect(page).to have_content "Second fabulous meeting!"
      end
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

    it "shows no data if there are no components or followers in depending participatory processes" do
      visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group)

      within(".section-statistics") do
        expect(page).to have_content("There are no statistics yet")
      end
    end

    context "when there are components and depending resources" do
      let(:process) { participatory_process_group.participatory_processes.first }
      let(:other_process) { participatory_process_group.participatory_processes.last }
      let!(:proposals_component) { create(:component, :published, participatory_space: process, manifest_name: :proposals) }
      let!(:other_process_proposals_component) { create(:component, :published, participatory_space: other_process, manifest_name: :proposals) }
      let!(:other_process_meetings_component) { create(:component, :published, participatory_space: other_process, manifest_name: :meetings) }
      let!(:user) { create(:user, organization:) }

      before do
        create_list(:proposal, 3, component: proposals_component)
        create_list(:proposal, 7, component: other_process_proposals_component)
        create_list(:meeting, 4, :published, component: other_process_meetings_component)

        # Set same coauthorships for all proposals
        Decidim::Proposals::Proposal.where(component: [proposals_component, other_process_proposals_component]).each do |proposal|
          proposal.coauthorships.clear
          proposal.coauthorships.create(author: user)
        end
        visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group)
      end

      it "shows unique participants count from both participatory processes" do
        within(".section-statistics") do
          expect(page).to have_css("h3.section-heading", text: "STATISTICS")
          expect(page).to have_css(".statistic__title", text: "PARTICIPANTS")
          expect(page).to have_css(".statistic__number", text: "1")
        end
      end

      it "shows accumulated resources from components of both participatory processes" do
        within(".section-statistics") do
          expect(page).to have_css("h3.section-heading", text: "STATISTICS")
          expect(page).to have_css(".statistic__title", text: "PROPOSALS")
          expect(page).to have_css(".statistic__number", text: "10")
          expect(page).to have_css(".statistic__title", text: "MEETINGS")
          expect(page).to have_css(".statistic__number", text: "4")
        end
      end
    end
  end

  context "when participatory processes block is enabled" do
    let!(:scope) { create :scope, organization: }
    let!(:area) { create :area, organization: }
    let!(:participatory_process_group) do
      create(
        :participatory_process_group,
        organization:
      )
    end
    let!(:past_process_with_scope) do
      create(
        :participatory_process,
        :published,
        :past,
        scope:,
        organization:,
        participatory_process_group:
      )
    end
    let!(:active_process) do
      create(
        :participatory_process,
        :published,
        :active,
        start_date: 1.year.ago,
        organization:,
        participatory_process_group:
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
        participatory_process_group:
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
        participatory_process_group:
      )
    end
    let!(:upcoming_process_with_area) do
      create(
        :participatory_process,
        :published,
        :upcoming,
        area:,
        organization:,
        participatory_process_group:
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
        participatory_process_group: create(:participatory_process_group, organization:)
      )
    end
    let(:titles) { page.all(".card__title") }

    shared_examples "showing all processes counts" do
      it "shows count of all group processes" do
        within "#processes-grid h3" do
          expect(page).to have_content(/ALL\s+\(5\)/)
        end
      end
    end

    shared_examples "not showing processes belonging to other group" do
      it "doesn't list process of other group" do
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
        manifest_name: :participatory_processes
      )
    end

    context "when no filters are set" do
      before do
        visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group)
      end

      it "lists active processes ordered by start_date" do
        within "#processes-grid" do
          expect(titles.count).to eq(3)
          expect(titles[0].text).to eq(translated(active_process_with_area.title, locale: :en))
          expect(titles[1].text).to eq(translated(active_process_with_scope.title, locale: :en))
          expect(titles[2].text).to eq(translated(active_process.title, locale: :en))
        end
      end

      it_behaves_like "showing all processes counts"
      it_behaves_like "not showing processes belonging to other group"

      it "shows counts of other processes" do
        within "#processes-grid h3" do
          expect(page).to have_content("3 ACTIVE PROCESSES")
          expect(page).to have_content(/UPCOMING\s+\(1\)/)
          expect(page).to have_content(/PAST\s+\(1\)/)
        end
      end
    end

    context "when filtering by date" do
      context "and choosing past processes" do
        before do
          visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group)
          within ".order-by__tabs" do
            click_link "Past"
          end
        end

        it "lists past process" do
          within "#processes-grid" do
            expect(titles.count).to eq(1)
            expect(titles.first.text).to eq(translated(past_process_with_scope.title, locale: :en))
          end
        end

        it_behaves_like "showing all processes counts"
        it_behaves_like "not showing processes belonging to other group"

        it "shows counts of processes" do
          within "#processes-grid h3" do
            expect(page).to have_content("1 PAST PROCESS")
            expect(page).to have_content(/UPCOMING\s+\(1\)/)
            expect(page).to have_content(/ACTIVE\s+\(3\)/)
          end
        end
      end

      context "and choosing upcoming processes" do
        before do
          visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group)
          within ".order-by__tabs" do
            click_link "Upcoming"
          end
        end

        it "lists ucpoming process" do
          within "#processes-grid" do
            expect(titles.count).to eq(1)
            expect(titles.first.text).to eq(translated(upcoming_process_with_area.title, locale: :en))
          end
        end

        it_behaves_like "showing all processes counts"
        it_behaves_like "not showing processes belonging to other group"

        it "shows counts of processes" do
          within "#processes-grid h3" do
            expect(page).to have_content("1 UPCOMING PROCESS")
            expect(page).to have_content(/PAST\s+\(1\)/)
            expect(page).to have_content(/ACTIVE\s+\(3\)/)
          end
        end
      end
    end

    context "when filtering processes by scope" do
      context "and choosing a scope" do
        before do
          visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group, filter: { with_scope: scope.id })
        end

        it "lists active process belonging to that scope" do
          within "#processes-grid" do
            expect(titles.count).to eq(1)
            expect(titles.first.text).to eq(translated(active_process_with_scope.title, locale: :en))
          end
        end

        it_behaves_like "not showing processes belonging to other group"

        it "shows counts of processes belonging to that scope" do
          within "#processes-grid h3" do
            expect(page).to have_content("1 ACTIVE PROCESS")
            expect(page).to have_content(/PAST\s+\(1\)/)
            expect(page).to have_content(/ALL\s+\(2\)/)
          end
        end
      end
    end

    context "when filtering processes by area" do
      context "and choosing a area" do
        before do
          visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group, filter: { with_area: area.id })
        end

        it "lists active process belonging to that area" do
          within "#processes-grid" do
            expect(titles.count).to eq(1)
            expect(titles.first.text).to eq(translated(active_process_with_area.title, locale: :en))
          end
        end

        it_behaves_like "not showing processes belonging to other group"

        it "shows counts of processes belonging to that area" do
          within "#processes-grid h3" do
            expect(page).to have_content("1 ACTIVE PROCESS")
            expect(page).to have_content(/UPCOMING\s+\(1\)/)
            expect(page).to have_content(/ALL\s+\(2\)/)
          end
        end
      end
    end
  end
end
