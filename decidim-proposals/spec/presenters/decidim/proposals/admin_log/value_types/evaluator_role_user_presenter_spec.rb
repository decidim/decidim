# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::AdminLog::ValueTypes::EvaluatorRoleUserPresenter, type: :helper do
  subject { described_class.new(value, helper) }

  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, organization:) }
  let(:component) { create(:proposal_component, participatory_space:) }
  let(:proposal) { create(:proposal, component:) }

  describe "#present" do
    context "when value is nil" do
      let(:value) { nil }

      it "returns nil" do
        expect(subject.present).to be_nil
      end
    end

    context "when the evaluation assignment exists" do
      let(:evaluation_assignment) { create(:evaluation_assignment, proposal:) }
      let(:value) { evaluation_assignment.evaluator_role_id }

      it "returns the evaluator's name" do
        expect(subject.present).to eq(evaluation_assignment.evaluator.name)
      end
    end

    context "when the evaluation assignment has been deleted" do
      let(:value) { 999_999 }

      it "returns nil" do
        expect(subject.present).to be_nil
      end
    end
  end
end
