# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/download_your_data_shared_examples"

module Decidim
  describe DownloadYourDataExporter do
    subject { DownloadYourDataExporter.new(user, "download-your-data", "CSV") }

    let(:user) { create(:user, organization:) }
    let(:organization) { create(:organization) }

    describe "#readme" do
      context "when the user has a conference invite" do
        let!(:conference_invite) { create(:conference_invite, user:) }
        let(:help_definition_string) { "The date when this conference invitation was sent" }

        it_behaves_like "a download your data entity"
      end

      context "when the user has a conference registration" do
        let!(:conference_registration) { create(:conference_registration, user:) }
        let(:help_definition_string) { "The type of registration that this belongs to" }

        it_behaves_like "a download your data entity"
      end
    end
  end
end
