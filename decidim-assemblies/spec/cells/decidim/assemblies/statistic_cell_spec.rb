# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe Decidim::StatisticCell, type: :cell do
    controller Decidim::ApplicationController

    subject { cell("decidim/statistic", model).call }

    context "when rendering participants count" do
      let(:model) { { name: :participants_count, data: [123] } }

      it "renders the stat wrapper" do
        expect(subject).to have_css("[data-statistic]")
      end

      it "renders the stat title" do
        expect(subject).to have_css(".statistic__title", text: "Participants")
      end

      it "renders the stat value" do
        expect(subject).to have_css(".statistic__number", text: "123")
      end
    end

    context "when rendering comments count" do
      let(:model) { { name: :comments_count, data: [25] } }

      it "renders the stat wrapper" do
        expect(subject).to have_css("[data-statistic]")
      end

      it "renders the stat title for comments" do
        expect(subject).to have_css(".statistic__title", text: "Comments")
      end

      it "renders the stat value" do
        expect(subject).to have_css(".statistic__number", text: "25")
      end
    end
  end
end
