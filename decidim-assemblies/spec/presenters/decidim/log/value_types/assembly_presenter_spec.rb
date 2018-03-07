# frozen_string_literal: true

require "spec_helper"

describe Decidim::Log::ValueTypes::AssemblyPresenter, type: :helper do
  subject { described_class.new(value, helper) }

  let(:value) { assembly.id }
  let!(:assembly) { create :assembly }

  before do
    helper.extend(Decidim::ApplicationHelper)
    helper.extend(Decidim::TranslationsHelper)
  end

  describe "#present" do
    context "when the assembly is found" do
      let(:title) { assembly.title["en"] }

      it "shows the assembly title" do
        expect(subject.present).to eq title
      end
    end

    context "when the assembly was not found" do
      let(:value) { assembly.id + 1 }

      it "shows a string explaining the problem" do
        expect(subject.present).to eq "The assembly was not found on the database (ID: #{value})"
      end
    end
  end
end
