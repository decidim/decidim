# frozen_string_literal: true

require "spec_helper"

module Decidim::Debates
  describe ReportedContentCell, type: :cell do
    controller Decidim::Debates::DebatesController

    let!(:debate) { create(:debate, title: { "en" => "the debate's title" }, description: { "en" => "the debate's description" }) }

    context "when rendering" do
      it "renders the debate's title and description" do
        html = cell("decidim/reported_content", debate).call
        expect(html).to have_content("the debate's title")
        expect(html).to have_content("the debate's description")
      end
    end
  end
end
