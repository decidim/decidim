# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe "NeedsRtlDirection" do
    let(:organization) { create(:organization) }
    let(:available_locales) { [:en, :ar] }

    controller do
      include Decidim::NeedsRtlDirection
    end

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
      allow(Decidim).to receive(:available_locales).and_return available_locales
      allow(I18n).to receive(:available_locales).and_return available_locales
      allow(I18n).to receive(:locale).and_return locale

      request.headers["Accept-Language"] = locale
    end

    describe "#rtl_direction" do
      context "when the locale is ltr" do
        let(:locale) { :en }

        it "returns ltr" do
          expect(subject.rtl_direction).to eq("ltr")
        end
      end

      context "when the locale is rtl" do
        let(:locale) { :ar }

        it "returns rtl" do
          expect(subject.rtl_direction).to eq("rtl")
        end
      end
    end
  end
end
