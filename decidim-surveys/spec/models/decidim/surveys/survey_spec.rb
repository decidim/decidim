# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    describe Survey do
      subject { survey }

      let(:survey) { create(:survey) }

      include_examples "has component"

      it { is_expected.to be_valid }

      context "without a component" do
        let(:survey) { build :survey, component: nil }

        it { is_expected.not_to be_valid }
      end

      context "without a valid component" do
        let(:survey) { build :survey, component: build(:component, manifest_name: "proposals") }

        it { is_expected.not_to be_valid }
      end

      it "has an associated component" do
        expect(survey.component).to be_a(Decidim::Component)
      end

      context "without a questionnaire" do
        let(:survey) { build :survey, questionnaire: nil }

        it { is_expected.not_to be_valid }
      end

      it "has an associated questionnaire" do
        expect(survey.questionnaire).to be_a(Decidim::Forms::Questionnaire)
      end
    end
  end
end
