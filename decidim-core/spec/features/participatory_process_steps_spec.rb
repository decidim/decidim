# coding: utf-8
# frozen_string_literal: true

require "spec_helper"

describe "Participatory Process Steps", type: :feature do
  let(:organization) { create(:organization) }
  let!(:participatory_process) do
    create(
      :participatory_process,
      organization: organization,
      description: { en: "Description", ca: "Descripció", es: "Descripción" },
      short_description: { en: "Short description", ca: "Descripció curta", es: "Descripción corta" }
    )
  end

  before do
    switch_to_host(organization.host)
  end

  context "when there are some processes with steps" do
    before do
      @steps = create_list(:participatory_process_step, 3, participatory_process: participatory_process)
      participatory_process.steps.first.update_attribute(:active, true)
      visit decidim.participatory_process_participatory_process_steps_path(participatory_process)
    end

    it "lists all the steps" do
      expect(page).to have_css(".timeline__item", count: 3)
      @steps.each do |step|
        expect(page).to have_content(/#{translated(step.title)}/i)
      end
    end
  end
end
