# frozen_string_literal: true

require "spec_helper"

describe Decidim::PaginateHelper do
  describe "#decidim_paginate" do
    let(:organization) { create(:organization) }
    let(:collection) { Decidim::StaticPage.page(1).per(per_page) }
    let(:paginate_params) { {} }

    before do
      create_list(:static_page, per_page + 1, organization:)

      allow(helper).to receive(:render).and_return("")
    end

    context "when per page is supported" do
      let(:per_page) { Decidim::Paginable::OPTIONS.first }

      it "renders the per page options" do
        expect(helper).to receive(:render).with(partial: "decidim/shared/results_per_page", locals: { per_page: }, formats: [:html])

        helper.decidim_paginate(collection, paginate_params)
      end
    end

    context "when per page is not supported" do
      let(:per_page) { Decidim::Paginable::OPTIONS.first - 1 }

      it "does not render the per page options" do
        expect(helper).not_to receive(:render).with(partial: "decidim/shared/results_per_page")

        helper.decidim_paginate(collection, paginate_params)
      end
    end
  end
end
