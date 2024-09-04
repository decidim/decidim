# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Events::SimpleEvent do
    let(:user) { build(:user) }

    subject do
      described_class.new(
        resource:,
        event_name: "some.event",
        user:,
        extra: {}
      )
    end

    describe "i18n_options?" do
      let(:resource) { create(:dummy_resource, title: { en: "<script>alert('Hey');</script>" }) }

      it "sanitizes the HTML tags from the i18n options" do
        expect(subject.i18n_options[:resource_title])
          .to eq "alert('Hey');"
      end
    end

    describe "hidden_resource?" do
      context "when resource is not moderated" do
        let(:resource) { create(:dummy_resource, title: { en: "<script>alert('Hey');</script>" }) }

        it "returns false" do
          expect(subject.hidden_resource?).to be false
        end
      end

      context "when resource is moderated" do
        let(:resource) { create(:dummy_resource, :moderated, title: { en: "<script>alert('Hey');</script>" }) }

        it "returns false" do
          expect(subject.hidden_resource?).to be true
        end
      end
    end
  end
end
