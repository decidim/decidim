# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe Decidim::Statistic, type: :cell do
    controller Decidim::ApplicationController

    subject { cell("decidim/statistic", model).call }

    let(:model) { { stat_title: :participants_count, stat_number: 123 } }

    context "when rendering" do
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
  end
end
