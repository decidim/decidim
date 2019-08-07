# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe AriaSelectedLinkToHelper do
      subject do
        Nokogiri::HTML(
          helper.aria_selected_link_to("Text", "url", options)
        )
      end

      let(:options) { {} }

      context "with options" do
        let(:options) { { class: "my_class" } }

        it "still uses the options hash" do
          expect(subject.css("a[class='my_class']")).not_to be_empty
        end
      end

      context "when it's ponting to the current path" do
        before do
          expect(helper)
            .to receive(:is_active_link?)
            .and_return true
        end

        it "adds the attribute with 'true' as value" do
          expect(subject.css("a[href='url'][aria-selected='true']")).not_to be_empty
        end
      end

      context "when it's ponting to the current path" do
        before do
          expect(helper)
            .to receive(:is_active_link?)
            .and_return false
        end

        it "adds the attribute with 'false' as value" do
          expect(subject.css("a[href='url'][aria-selected='false']")).not_to be_empty
        end
      end
    end
  end
end
