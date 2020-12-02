# frozen_string_literal: true

require "spec_helper"

describe "Participatory Process Groups", type: :system do
  let(:organization) { create(:organization) }
  let(:other_organization) { create(:organization) }
  let!(:participatory_process_group) do
    create(
      :participatory_process_group,
      :with_participatory_processes,
      organization: organization,
      title: { en: "Title", ca: "Títol", es: "Título" },
      hashtag: "my_awesome_hashtag",
      group_url: "https://www.example.org/external"
    )
  end
  let(:group_processes) { participatory_process_group.participatory_processes }
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

  describe "show" do
    context "when the title_content block is enabled" do
      before do
        create(
          :content_block,
          organization: organization,
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
          organization: organization,
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
          organization: organization,
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
      let(:process) { participatory_process_group.participatory_processes.first }
      let(:other_process) { participatory_process_group.participatory_processes.last }
      let!(:proposals_component) { create(:component, :published, participatory_space: process, manifest_name: :proposals) }
      let!(:other_process_proposals_component) { create(:component, :published, participatory_space: other_process, manifest_name: :proposals) }
      let!(:proposal_1) { create(:proposal, component: proposals_component, title: { en: "First awesome proposal!" }) }
      let!(:proposal_2) { create(:proposal, component: other_process_proposals_component, title: { en: "Second fabulous proposal!" }) }

      before do
        create(
          :content_block,
          organization: organization,
          scope_name: :participatory_process_group_homepage,
          scoped_resource_id: participatory_process_group.id,
          manifest_name: :highlighted_proposals
        )

        visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group)
      end

      it "shows cards of proposals from both processes" do
        within("#participatory-process-group-homepage-highlighted-proposals") do
          expect(page).to have_selector("#proposal_#{proposal_1.id}")
          expect(page).to have_selector("#proposal_#{proposal_2.id}")

          within("#proposal_#{proposal_1.id}") do
            expect(page).to have_content "First awesome proposal!"
            expect(page).to have_i18n_content process.title
          end

          within("#proposal_#{proposal_2.id}") do
            expect(page).to have_content "Second fabulous proposal!"
            expect(page).to have_i18n_content other_process.title
          end
        end
      end
    end

    context "when the results block is enabled" do
      let(:process) { participatory_process_group.participatory_processes.first }
      let(:other_process) { participatory_process_group.participatory_processes.last }
      let!(:accountability_component) { create(:component, :published, participatory_space: process, manifest_name: :accountability) }
      let!(:other_process_accountability_component) { create(:component, :published, participatory_space: other_process, manifest_name: :accountability) }
      let!(:result_1) { create(:result, component: accountability_component, title: { en: "First awesome result!" }) }
      let!(:result_2) { create(:result, component: other_process_accountability_component, title: { en: "Second fabulous result!" }) }

      before do
        create(
          :content_block,
          organization: organization,
          scope_name: :participatory_process_group_homepage,
          scoped_resource_id: participatory_process_group.id,
          manifest_name: :highlighted_results
        )

        visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group)
      end

      it "shows cards of results from both processes" do
        within("#participatory-process-group-homepage-highlighted-results") do
          expect(page).to have_selector("#result_#{result_1.id}")
          expect(page).to have_selector("#result_#{result_2.id}")

          within("#result_#{result_1.id}") do
            expect(page).to have_content "First awesome result!"
            expect(page).to have_i18n_content process.title
          end

          within("#result_#{result_2.id}") do
            expect(page).to have_content "Second fabulous result!"
            expect(page).to have_i18n_content other_process.title
          end
        end
      end
    end

    context "when the html block is enabled" do
      before do
        create(
          :content_block,
          organization: organization,
          scope_name: :participatory_process_group_homepage,
          scoped_resource_id: participatory_process_group.id,
          manifest_name: :html_1,
          settings: {
            html_content_ca: nil,
            html_content_en: "<div id=\"testing-html\">HTML block</div>",
            html_content_es: nil
          }
        )

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
end
