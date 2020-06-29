# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe ProcessCell, type: :cell do
    controller Decidim::ApplicationController

    subject { cell("decidim/participatory_processes/process", model).call }

    let(:model) { create(:participatory_process) }

    context "when rendering" do
      it "renders the card" do
        expect(subject).to have_css(".card--process")
      end
    end
  end
end
