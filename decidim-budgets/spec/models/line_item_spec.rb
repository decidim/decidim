# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::LineItem do
  let(:line_item) { build :line_item }
  subject { line_item }

  describe "validations" do
    it "is valid" do
      expect(subject).to be_valid
    end

    it "is invalid when order is not present" do
      subject.order = nil
      expect(subject).to be_invalid
    end

    it "is invalid when project is not present" do
      subject.project = nil
      expect(subject).to be_invalid
    end

    it "is invalid when the same litem item exists" do
      subject.save
      new_line_item = build :line_item, order: subject.order, project: subject.project
      expect(new_line_item).to be_invalid
    end

    it "is invalid when order and project are from a different feature" do
      subject.order = build(:order)
      expect(subject).to be_invalid
    end
  end
end
