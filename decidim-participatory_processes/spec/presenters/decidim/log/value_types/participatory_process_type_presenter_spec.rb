# frozen_string_literal: true

require "spec_helper"

describe Decidim::Log::ValueTypes::ParticipatoryProcessTypePresenter, type: :helper do
  subject { described_class.new(value, helper) }

  let(:value) { participatory_process_type.id }
  let!(:participatory_process_type) { create :participatory_process_type }

  before do
    helper.extend(Decidim::ApplicationHelper)
    helper.extend(Decidim::TranslationsHelper)
  end

  describe "#present" do
    context "when the participatory process type is found" do
      let(:title) { participatory_process_type.title["en"] }

      it "shows the participatory process type title" do
        expect(subject.present).to eq title
      end
    end

    context "when the participatory process type was not found" do
      let(:value) { participatory_process_type.id + 1 }

      it "shows a string explaining the problem" do
        expect(subject.present).to eq "The process type was not found on the database (ID: #{value})"
      end
    end
  end
end
