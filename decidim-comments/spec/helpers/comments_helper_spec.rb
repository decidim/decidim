# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CommentsHelper do
      let(:dummy_resource) { create(:dummy_resource) }
      let(:machine_translations_toggled?) { false }

      before do
        allow(helper)
          .to receive(:machine_translations_toggled?)
          .and_return(machine_translations_toggled?)
      end

      describe "comments_for" do
        let(:cell) { double }

        it "renders the comments cell with the correct data" do
          allow(helper)
            .to receive(:machine_translations_toggled?)
            .and_return(machine_translations_toggled?)

          expect(cell).to receive(:to_s)

          allow(helper)
            .to receive(:cell)
            .with(
              "decidim/comments/comments",
              dummy_resource,
              machine_translations: machine_translations_toggled?,
              single_comment: nil,
              order: nil,
              polymorphic: nil
            ).and_return(cell)

          helper.comments_for(dummy_resource)
        end
      end
    end
  end
end
