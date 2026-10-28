# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe EvaluationAssignment do
      subject { evaluation_assignment }

      let(:evaluation_assignment) { create(:evaluation_assignment) }

      it { is_expected.to be_valid }
      it { is_expected.to be_versioned }

      it "uses the proposal's evaluation_assignments association as the inverse" do
        expect(evaluation_assignment.proposal.evaluation_assignments.first.proposal).to be(evaluation_assignment.proposal)
      end
    end
  end
end
