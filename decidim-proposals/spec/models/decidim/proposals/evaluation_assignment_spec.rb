# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe EvaluationAssignment do
      subject { evaluation_assignment }

      let(:evaluation_assignment) { create(:evaluation_assignment) }

      it { is_expected.to be_valid }
      it { is_expected.to be_versioned }
    end
  end
end
