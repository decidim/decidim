# frozen_string_literal: true

require "spec_helper"

describe "Participatory Processes", type: :system, download: true do
  let(:date) { Time.zone.today - 1.week }
  let(:organization) { create(:organization) }
  let(:show_statistics) { true }
  let(:participatory_process) do
    create(
      :participatory_process,
      organization: organization,
      show_statistics: show_statistics
    )
  end

  context "when statistics are enabled" do
    before do
      switch_to_host(organization.host)
      visit decidim_participatory_processes.statistics_participatory_process_path(participatory_process)
    end

    it "renders the statistics" do
      expect(page).to have_css("#participatory_process-statistics")
    end
  end

  context "when show statistics are disabled" do
    let(:show_statistics) { false }

    before do
      switch_to_host(organization.host)
      visit decidim_participatory_processes.statistics_participatory_process_path(participatory_process)
    end

    it "does not render any statistic" do
      expect(page).not_to have_css("#participatory_process-statistics")
    end
  end
end
