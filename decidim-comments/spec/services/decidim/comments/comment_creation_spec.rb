# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CommentCreation do
      let(:comment) { create(:comment) }
      let(:expected_metadatas) { "the data that is expected to be published." }

      describe "#publish" do
        it "boradcasts comment created" do
          expect(ActiveSupport::Notifications)
            .to receive(:publish)
            .with(
              described_class::EVENT_NAME,
              comment_id: comment.id,
              metadatas: expected_metadatas
            )

          described_class.publish(comment, expected_metadatas)
        end
      end

      describe "#subscribe" do
        let(:block) { proc { |_data| "The block that is expected to be subscribed" } }

        it "subscribes to comment created" do
          allow(ActiveSupport::Notifications)
            .to receive(:subscribe)
            .with(described_class::EVENT_NAME, &block)

          described_class.subscribe(&block)
        end
      end
    end
  end
end
