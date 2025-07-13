# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/download_your_data_shared_examples"

module Decidim
  describe DownloadYourDataExporter do
    subject { DownloadYourDataExporter.new(user, "download-your-data", "CSV") }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, organization:) }
    let(:component) { create(:budgets_component, organization:) }
    let(:budget) { create(:budget, component:) }

    describe "#readme" do
      context "when the user has a budgets' order" do
        let!(:order) { create(:order, budget:, user:) }
        let(:help_definition_string) { "The projects that the order has voted on" }

        it_behaves_like "a download your data entity"
      end
    end
  end
end
