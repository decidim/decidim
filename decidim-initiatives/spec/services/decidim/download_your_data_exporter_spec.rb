# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/download_your_data_shared_examples"

module Decidim
  describe DownloadYourDataExporter do
    subject { DownloadYourDataExporter.new(user, "download-your-data", "CSV") }

    let(:user) { create(:user, :confirmed, organization:) }
    let(:organization) { create(:organization) }

    describe "#readme" do
      context "when the user has an initiative" do
        let(:initiatives_type) { create(:initiatives_type, organization:) }
        let(:scope) { create(:initiatives_type_scope, type: initiatives_type) }
        let!(:initiative) { create(:initiative, author: user, organization:, scoped_type: scope) }

        let(:help_definition_string) { "The title of the initiative" }

        it_behaves_like "a download your data entity"
      end
    end
  end
end
