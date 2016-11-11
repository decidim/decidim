require "spec_helper"

module Decidim
  module Admin
    describe AriaSelectedLinkToHelper do
      context "when it's ponting to the current path" do
        before do
          expect(helper)
            .to receive(:is_active_link?)
            .and_return true
        end

        subject do
          helper.aria_selected_link_to("Text", "url")
        end

        it "adds the attribute with 'true' as value" do
          expect(subject).to eq "<a aria-selected=\"true\" href=\"url\">Text</a>"
        end
      end

      context "when it's ponting to the current path" do
        before do
          expect(helper)
            .to receive(:is_active_link?)
            .and_return false
        end

        subject do
          helper.aria_selected_link_to("Text", "url")
        end

        it "adds the attribute with 'true' as value" do
          expect(subject).to eq "<a aria-selected=\"false\" href=\"url\">Text</a>"
        end
      end
    end
  end
end
