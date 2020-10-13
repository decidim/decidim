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
      title: { en: "Title", ca: "Títol", es: "Título" }
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
    let!(:unpublished_group_processes) do
      create_list(:participatory_process, 2, :unpublished, organization: organization, participatory_process_group: participatory_process_group)
    end

    before do
      visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group)
    end

    it "lists all the processes" do
      within "#processes-grid" do
        within "#processes-grid h1" do
          expect(page).to have_content("2")
        end

        expect(page).to have_content(translated(group_processes.first.title, locale: :en))
        expect(page).to have_selector(".card", count: 2)

        expect(page).to have_no_content(translated(unpublished_group_processes.first.title, locale: :en))
      end
    end

    it "links to the individual process page" do
      first(".card__link", text: translated(group_processes.first.title, locale: :en)).click

      expect(page).to have_current_path decidim_participatory_processes.participatory_process_path(group_processes.first)
    end
  end
end
