# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Events::SimpleEvent do
    let(:user) { build(:user) }

    describe "i18n_options?" do
      subject do
        described_class.new(
          resource:,
          event_name: "some.event",
          user:,
          extra: {}
        )
      end

      let(:resource) { create(:dummy_resource, title: { en: "<script>alert('Hey');</script>" }) }

      it "escapes the HTML tags from the i18n options" do
        expect(subject.i18n_options[:resource_title])
          .to eq "alert('Hey');"
      end
    end
  end
end
