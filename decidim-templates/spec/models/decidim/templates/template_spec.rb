# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Templates
    describe Template do
      subject { template }

      let(:template) { create(:template) }

      it { is_expected.to be_valid }

      context "without an organization" do
        let(:template) { build :template, organization: nil }

        it { is_expected.not_to be_valid }
      end

      context "without a name" do
        let(:template) { build :template, name: nil }

        it { is_expected.not_to be_valid }
      end

      it "has an associated templatable" do
        expect(subject.templatable).to be_a(Decidim::DummyResources::DummyResource)
      end

      describe "on destroy" do
        let(:templatable) { template.templatable }

        it "destroys the templatable" do
          template.destroy!
          expect { templatable.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      describe "#resource_name" do
        it "returns the templatable model name without namespace, downcased and postfixed with _templates" do
          expect(template.resource_name).to eq("dummy_resource_templates")
        end
      end
    end

    describe "Questionnaire Template" do
      subject { questionnaire_template }

      let(:questionnaire_template) { create(:questionnaire_template) }

      it "has an associated questionnaire as templatable" do
        expect(subject.templatable).to be_a(Decidim::Forms::Questionnaire)
      end

      it "has the right resource_name" do
        expect(subject.resource_name).to eq("questionnaire_templates")
      end
    end
  end
end
