# frozen_string_literal: true

require "spec_helper"

describe "Participatory Process Groups", type: :feature do
  let(:organization) { create(:organization) }
  let(:other_organization) { create(:organization) }
  let!(:participatory_process_group) do
    create(
      :participatory_process_group,
      organization: organization,
      name: { en: "Name", ca: "Nom", es: "Nombre" }
    )
  end

  before do
    switch_to_host(organization.host)
  end

  context "when there are some groups" do
    let!(:other_group) { create(:participatory_process_group, organization: other_organization) }

    before do
      visit decidim.participatory_processes_path
    end

    it "lists all the groups" do
      within "#processes-grid" do
        expect(page).to have_content(translated(participatory_process_group.name, locale: :en))
        expect(page).to have_selector("article.card", count: 1)

        expect(page).to have_no_content(translated(other_group.name, locale: :en))
      end
    end

    it "links to the individual group page" do
      click_link(translated(participatory_process_group.name, locale: :en))

      expect(current_path).to eq decidim.participatory_process_group_path(participatory_process_group)
    end
  end

  context "when the group does not exist" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim.participatory_process_group_path(99_999_999) }
    end
  end

  describe "show" do
    let!(:participatory_process_group) { create(:participatory_process_group, organization: organization) }
    let!(:group_processes) { create_list(:participatory_process, 2, :published, organization: organization, participatory_process_group: participatory_process_group) }

    let!(:unpublished_group_processes) do
      create_list(:participatory_process, 2, :unpublished, organization: organization, participatory_process_group: participatory_process_group)
    end

    before do
      visit decidim.participatory_process_group_path(participatory_process_group)
    end

    it "lists all the processes" do
      within "#processes-grid" do
        within "#processes-grid h2" do
          expect(page).to have_content("2")
        end

        expect(page).to have_content(translated(group_processes.first.title, locale: :en))
        expect(page).to have_selector("article.card", count: 2)

        expect(page).to have_no_content(translated(unpublished_group_processes.first.title, locale: :en))
      end
    end

    it "links to the individual process page" do
      click_link(translated(group_processes.first.title, locale: :en))

      expect(current_path).to eq decidim.participatory_process_path(group_processes.first)
    end
  end
end
