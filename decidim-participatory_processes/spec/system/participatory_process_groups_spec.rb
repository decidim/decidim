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
  end
end
