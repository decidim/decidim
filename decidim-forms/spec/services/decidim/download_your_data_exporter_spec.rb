# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/download_your_data_shared_examples"

module Decidim
  describe DownloadYourDataExporter do
    subject { DownloadYourDataExporter.new(user, "download-your-data", "CSV") }

    let(:user) { create(:user, organization:) }
    let(:organization) { create(:organization) }

    describe "#readme" do
      context "when the user has an answer" do
        let(:participatory_process) { create(:participatory_process, organization:) }
        let(:questionnaire) { create(:questionnaire, questionnaire_for: participatory_process) }
        let(:question) { create(:questionnaire_question, questionnaire:) }
        let!(:answer) { create(:answer, questionnaire:, question:, user:) }
        let(:help_definition_string) { "The answer to the question" }

        it_behaves_like "a download your data entity"
      end
    end
  end
end
