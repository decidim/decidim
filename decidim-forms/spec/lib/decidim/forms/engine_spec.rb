# frozen_string_literal: true

require "spec_helper"

describe Decidim::Forms::Engine do
  it_behaves_like "clean engine"

  describe "decidim_forms.authorization_transfer" do
    include_context "authorization transfer"

    let(:questionnaire_for) { create(:participatory_process, organization:) }
    let(:questionnaire) { create(:questionnaire, questionnaire_for:) }
    let(:submission) { create(:submission, questionnaire:, user: original_user) }
    let(:original_records) { { submissions: [submission], responses: create_list(:response, 3, questionnaire:, user: original_user, submission:) } }
    let(:transferred_responses) { Decidim::Forms::Response.where(user: target_user).order(:id) }
    let(:transferred_submissions) { Decidim::Forms::Submission.where(user: target_user).order(:id) }

    it "handles authorization transfer correctly" do
      expect(transferred_responses.count).to eq(3)
      expect(transferred_submissions.count).to eq(1)
      expect(transfer.records.count).to eq(4)
      expect(transferred_resources).to eq(transferred_responses + transferred_submissions)
    end
  end
end
