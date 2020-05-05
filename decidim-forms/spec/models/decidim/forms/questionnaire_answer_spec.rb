# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe QuestionnaireAnswer do
      subject { answer }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, organization: organization) }
      let(:participatory_process) { create(:participatory_process, organization: organization) }
      let(:questionnaire) { create(:questionnaire, questionnaire_for: participatory_process) }
      let(:answer) { create(:answer, questionnaire: questionnaire, user: user) }

      it { is_expected.to be_valid }

      it "has an association of questionnaire" do
        expect(subject.questionnaire).to eq(questionnaire)
      end

      it "has an association of user" do
        expect(subject.user).to eq(user)
      end

      context "when the user doesn't belong to the same organization" do
        it "is not valid" do
          subject.user = create(:user)
          expect(subject).not_to be_valid
        end
      end
    end
  end
end
