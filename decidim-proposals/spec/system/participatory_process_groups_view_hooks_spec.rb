# frozen_string_literal: true

require "spec_helper"

describe "Proposals in process group home", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }
  let(:proposals_count) { 5 }

  let!(:participatory_process_group) do
    create(
      :participatory_process_group,
      participatory_processes: [participatory_process],
      organization: organization,
      name: { en: "Name", ca: "Nom", es: "Nombre" }
    )
  end

  context "when there are no proposals" do
    it "does not show the highlighted proposals section" do
      visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group)
      expect(page).not_to have_css(".highlighted_proposals")
    end
  end

  context "when there are proposals" do
    let!(:proposals) do
      create_list(:proposal, proposals_count, component: component)
    end

    it "shows the highlighted proposals section" do
      visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group)

      within ".highlighted_proposals" do
        expect(page).to have_css(".card--proposal", count: 3)

        proposals_titles = proposals.map(&:title)
        highlighted_proposals = page.all(".card--proposal .card__title").map(&:text)
        expect(proposals_titles).to include(*highlighted_proposals)
      end
    end

    context "when scopes enabled and proposals not in top scope" do
      let(:main_scope) { create(:scope, organization: organization) }
      let(:child_scope) { create(:scope, parent: main_scope) }

      before do
        participatory_process.update!(scopes_enabled: true, scope: main_scope)
        proposals.each { |proposal| proposal.update!(scope: child_scope) }
      end

      it "shows a tag with the proposals scope" do
        visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group)

        expect(page).to have_selector(".tags", text: child_scope.name["en"], count: 3)
      end
    end
  end
end
