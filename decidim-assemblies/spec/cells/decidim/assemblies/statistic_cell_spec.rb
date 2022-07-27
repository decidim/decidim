# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe Decidim::StatisticCell, type: :cell do
    controller Decidim::ApplicationController

    subject { cell("decidim/statistic", model).call }

    context "when rendering participants count" do
      let(:model) { { stat_title: :participants_count, stat_number: 123 } }

      it "renders the stat wrapper" do
        expect(subject).to have_css(".statistic__data")
      end

      it "renders the stat title" do
        expect(subject).to have_css("h4.statistic__title", text: "Participants")
      end

      it "renders the stat value" do
        expect(subject).to have_css("span.statistic__number", text: "123")
      end
    end

    context "when rendering comments count" do
      let(:model) { { stat_title: :comments_count, stat_number: 25 } }

      it "renders the stat wrapper" do
        expect(subject).to have_css(".statistic__data")
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
