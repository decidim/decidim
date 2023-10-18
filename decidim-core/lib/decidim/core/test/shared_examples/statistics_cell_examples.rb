# frozen_string_literal: true

require "spec_helper"

shared_examples "statistics cell" do
  subject { cell("decidim/statistics", model).call }

  context "when rendering" do
    it "renders each stat" do
      expect(subject).to have_css("[data-statistic]", count: model.count)
    end
  end
end
