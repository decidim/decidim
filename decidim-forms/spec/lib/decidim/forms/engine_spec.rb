# frozen_string_literal: true

require "spec_helper"

describe Decidim::Forms::Engine do
  describe "decidim_forms.authorization_transfer" do
    include_context "authorization transfer"

    let(:questionnaire_for) { create(:participatory_process, organization:) }
    let(:questionnaire) { create(:questionnaire, questionnaire_for:) }
    let(:original_records) do
      { answers: create_list(:answer, 3, questionnaire:, user: original_user) }
    end
    let(:transferred_answers) { Decidim::Forms::Answer.where(user: target_user).order(:id) }

    it "handles authorization transfer correctly" do
      expect(transferred_answers.count).to eq(3)
      expect(transfer.records.count).to eq(3)
      expect(transferred_resources).to eq(transferred_answers)
    end
  end
end
