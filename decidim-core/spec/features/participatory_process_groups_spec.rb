# coding: utf-8
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

        expect(page).not_to have_content(translated(other_group.name, locale: :en))
      end
    end

    it "links to the individial group page" do
      click_link(translated(participatory_process_group.name, locale: :en))

      expect(current_path).to eq decidim.participatory_process_group_path(participatory_process_group)
    end
  end
end
