# frozen_string_literal: true

require "spec_helper"

describe Decidim::Log::ValueTypes::ScopePresenter, type: :helper do
  subject { described_class.new(value, helper) }

  let(:value) { scope.id }
  let!(:scope) { create :scope }

  before do
    helper.extend(Decidim::ApplicationHelper)
    helper.extend(Decidim::TranslationsHelper)
  end

  describe "#present" do
    context "when the scope is found" do
      let(:title) { scope.name["en"] }

      it "shows the scope title" do
        expect(subject.present).to eq title
      end
    end

    context "when the scope isn't found" do
      let(:value) { scope.id + 1 }

      it "shows a string explaining the problem" do
        expect(subject.present).to eq "The scope was not found on the database (ID: #{value})"
      end
    end
  end
end
