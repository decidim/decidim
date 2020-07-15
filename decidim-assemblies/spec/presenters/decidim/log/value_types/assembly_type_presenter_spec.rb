# frozen_string_literal: true

require "spec_helper"

describe Decidim::Log::ValueTypes::AssemblyTypePresenter, type: :helper do
  subject { described_class.new(value, helper) }

  let(:value) { assembly_type.id }
  let!(:assembly_type) { create :assemblies_type }

  before do
    helper.extend(Decidim::ApplicationHelper)
    helper.extend(Decidim::TranslationsHelper)
  end

  describe "#present" do
    context "when the assembly type is found" do
      let(:title) { assembly_type.title["en"] }

      it "shows the assembly type title" do
        expect(subject.present).to eq title
      end
    end

    context "when the assembly type was not found" do
      let(:value) { assembly_type.id + 1 }

      it "shows a string explaining the problem" do
        expect(subject.present).to eq "The assembly type was not found on the database (ID: #{value})"
      end
    end
  end
end
