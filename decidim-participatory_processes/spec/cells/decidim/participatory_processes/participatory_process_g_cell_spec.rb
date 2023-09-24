# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe ProcessGCell, type: :cell do
    controller Decidim::ApplicationController

    subject { cell("decidim/participatory_processes/process_g", model).call }

    let(:model) { create(:participatory_process) }

    context "when rendering" do
      let(:show_space) { false }

      it "renders the card" do
        expect(subject).to have_css(".card__grid")
      end

      it "displays the process title" do
        expect(subject).to have_css(".card__grid-text", text: translated(model.title))
      end

      it "displays the process hero image" do
        expect(subject).to have_css("img[src='#{model.attached_uploader(:hero_image).path}']")
      end

      it_behaves_like "process card with metadata", metadata_class: "card__grid-metadata"
    end
  end
end
