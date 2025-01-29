# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/download_your_data_shared_examples"

module Decidim
  describe DownloadYourDataExporter do
    subject { DownloadYourDataExporter.new(user, "download-your-data", "CSV") }

    let(:user) { create(:user, organization:) }
    let(:organization) { create(:organization) }

    describe "#readme" do
      context "when the user has a meeting registration" do
        let(:meeting) { create(:meeting, :published, questionnaire:) }
        let(:questionnaire) { create(:questionnaire) }
        let(:question) { create(:questionnaire_question, questionnaire:, position: 0) }
        let!(:registration) { create(:registration, meeting:, user:) }

        let(:help_definition_string) { "The registration code" }

        it_behaves_like "a download your data entity"
      end

      context "when the user has a meeting invitation" do
        let!(:invite) { create(:invite, :accepted, user:, meeting:) }
        let(:meeting) { create(:meeting, component:) }
        let(:participatory_space) { create(:participatory_process, organization:) }
        let(:component) { create(:component, manifest_name: :meetings, participatory_space:) }

        let(:help_definition_string) { "The unique identifier for this invitation" }

        it_behaves_like "a download your data entity"
      end
    end
  end
end
