# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ActiveLinkToHelper do
    let(:helper) do
      Class.new(ActionView::Base) do
        include ActiveLinkTo
        include Decidim::ActiveLinkToHelper
      end.new(ActionView::LookupContext.new([]), {}, nil)
    end

    before do
      allow(helper).to receive(:request).and_return(double("request", original_fullpath: current_path))
      allow(helper).to receive(:params).and_return({})
      allow(helper).to receive(:current_locale).and_return("en")
      allow(helper).to receive(:available_locales).and_return([:en, :ca, :es])
      allow(helper).to receive(:locale_in_script_name?).and_return(false)
    end

    describe "#is_active_link?" do
      context "when the current path includes a locale prefix" do
        let(:current_path) { "/en/processes" }

        it "returns true when given the same locale-prefixed URL" do
          expect(helper.is_active_link?("/en/processes")).to be(true)
        end

        it "returns true when given the URL without locale prefix" do
          expect(helper.is_active_link?("/processes")).to be(true)
        end

        it "returns true for child paths (inclusive mode)" do
          allow(helper).to receive(:request).and_return(double("request", original_fullpath: "/en/processes/my-process"))
          expect(helper.is_active_link?("/processes")).to be(true)
        end

        it "returns false for a different path" do
          expect(helper.is_active_link?("/assemblies")).to be(false)
        end

        it "returns false for a different locale-prefixed path" do
          expect(helper.is_active_link?("/en/assemblies")).to be(false)
        end

        it "normalizes locale prefix from a different locale in the URL" do
          # URL has /ca/ prefix but current locale is en - should still match
          # because we strip and re-add the current locale
          expect(helper.is_active_link?("/ca/processes")).to be(true)
        end
      end

      context "when locale is in the script name" do
        let(:current_path) { "/processes" }

        before do
          allow(helper).to receive(:locale_in_script_name?).and_return(true)
        end

        it "does not normalize and compares URLs as-is" do
          expect(helper.is_active_link?("/processes")).to be(true)
        end

        it "returns false for a locale-prefixed URL when fullpath has no locale" do
          expect(helper.is_active_link?("/en/processes")).to be(false)
        end
      end

      context "when the current path has no locale prefix (e.g. admin engine)" do
        let(:current_path) { "/admin/users" }

        it "returns true when the URL matches as-is" do
          expect(helper.is_active_link?("/admin/users")).to be(true)
        end

        it "returns false for a different path" do
          expect(helper.is_active_link?("/admin/static-pages")).to be(false)
        end

        it "does not normalize a locale-prefixed URL argument" do
          # A URL that happens to have a locale prefix should not match a
          # non-locale-prefixed request path
          expect(helper.is_active_link?("/en/admin/users")).to be(false)
        end

        it "returns true for child paths (inclusive mode)" do
          allow(helper).to receive(:request).and_return(double("request", original_fullpath: "/admin/users/1"))
          expect(helper.is_active_link?("/admin/users")).to be(true)
        end
      end
    end
  end
end
