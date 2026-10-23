# frozen_string_literal: true

require "spec_helper"

describe "Participatory Process Phases" do
  let(:organization) { create(:organization) }
  let!(:participatory_process) do
    create(
      :participatory_process,
      :with_content_blocks,
      organization:,
      description: { en: "Description", ca: "Descripció", es: "Descripción" },
      short_description: { en: "Short description", ca: "Descripció curta", es: "Descripción corta" }
    )
  end

  before do
    switch_to_host(organization.host)
  end

  context "when there are some processes with phases" do
    let!(:phases) do
      create_list(:participatory_process_phase, 3, participatory_process:)
    end

    before do
      participatory_process.phases.first.update!(active: true)
    end

    it_behaves_like "accessible page" do
      before do
        visit decidim_participatory_processes.participatory_process_path(participatory_process, locale: I18n.locale, display_phases: true)
      end
    end

    context "when activating a phase" do
      let!(:user) { create(:user, :confirmed, organization:) }
      let!(:follow) { create(:follow, user:, followable: participatory_process) }

      before do
        participatory_process.phases.first.update!(active: true)
        Decidim::ParticipatoryProcesses::Admin::ActivateParticipatoryProcessPhase.call(phases.last, user)
        login_as user, scope: :user
        switch_to_host(organization.host)
      end

      it "triggers a notification" do
        wait_enqueued_jobs do
          visit decidim.notifications_path
          expect(page).to have_text("phase is now active for")
        end
      end
    end

    it "lists all the phases" do
      visit decidim_participatory_processes.participatory_process_path(participatory_process, locale: I18n.locale, display_phases: true)

      expect(page).to have_css(".participatory-space__metadata-modal__phase", count: 3)
      phases.each do |phase|
        expect(page).to have_text(translated(phase.title))
      end
    end
  end
end
