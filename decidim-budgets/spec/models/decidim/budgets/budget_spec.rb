# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::Budget do
  subject(:budget) { build(:budget) }

  it { is_expected.to be_valid }

  include_examples "has component"
  include_examples "resourceable"
  include_examples "has scope"

  describe "check the log result" do
    it "overwrites the log presenter" do
      expect(described_class.log_presenter_class_for(:foo))
        .to eq Decidim::Budgets::AdminLog::BudgetPresenter
    end
  end
end
