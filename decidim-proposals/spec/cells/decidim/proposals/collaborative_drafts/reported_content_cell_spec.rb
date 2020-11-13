# frozen_string_literal: true

require "spec_helper"

module Decidim::Proposals::CollaborativeDrafts
  describe ReportedContentCell, type: :cell do
    controller Decidim::Proposals::CollaborativeDraftsController

    let!(:collaborative_draft) { create(:collaborative_draft, body: { "en" => "a nice body" }) }

    context "when rendering" do
      it "renders the collaborative draft's body" do
        html = cell("decidim/reported_content", collaborative_draft).call
        expect(html).to have_content("a nice body")
      end
    end
  end
end
