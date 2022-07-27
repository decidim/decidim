# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/factories"
require "decidim/accountability/test/factories"
require "decidim/participatory_processes/test/factories"

describe Decidim::Accountability::ResultsCsvImporter do
  let(:organization) { create :organization, available_locales: [:en] }
  let(:current_user) { create :user, organization: }
  let(:participatory_process) { create :participatory_process, organization: }
  let(:current_component) { create :accountability_component, participatory_space: participatory_process, id: 16 }
  let!(:category) { create :category, id: 16, participatory_space: current_component.participatory_space }
  let!(:status6) { create :status, id: 6, component: current_component }
  let!(:status7) { create :status, id: 7, component: current_component }
  let!(:status8) { create :status, id: 8, component: current_component }
  let(:valid_csv) { File.read("spec/fixtures/valid_result.csv") }
  let(:invalid_csv) { File.read("spec/fixtures/invalid_result.csv") }

  context "with a valid CSV" do
    subject { described_class.new(current_component, valid_csv, current_user) }

    describe "#import!" do
      it "Import all rows from csv file" do
        expect do
          subject.import!
        end.to change(Decidim::Accountability::Result, :count).by(4)
      end

      context "when results exist" do
        let!(:result1) { create :result, component: current_component, progress: 0, id: 69, status: status6 }

        it "Update the result1 progress attribute" do
          subject.import!

          expect(result1.reload.progress.to_f).to eq 96.0
        end
      end
    end
  end

  context "with an invalid CSV" do
    subject { described_class.new(current_component, invalid_csv, current_user) }

    describe "#import!" do
      it "Errors would be returned" do
        errors = subject.import!

        expect(errors.length).to eq 3
      end
    end
  end
end
