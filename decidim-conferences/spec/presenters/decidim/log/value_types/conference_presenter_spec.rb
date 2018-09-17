# frozen_string_literal: true

require "spec_helper"

describe Decidim::Log::ValueTypes::ConferencePresenter, type: :helper do
  subject { described_class.new(value, helper) }

  let(:value) { conference.id }
  let!(:conference) { create :conference }

  before do
    helper.extend(Decidim::ApplicationHelper)
    helper.extend(Decidim::TranslationsHelper)
  end

  describe "#present" do
    context "when the conference is found" do
      let(:title) { conference.title["en"] }

      it "shows the conference title" do
        expect(subject.present).to eq title
      end
    end

    context "when the conference was not found" do
      let(:value) { conference.id + 1 }

      it "shows a string explaining the problem" do
        expect(subject.present).to eq "The conference was not found on the database (ID: #{value})"
      end
    end
  end
end
