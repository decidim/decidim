# frozen_string_literal: true

require "spec_helper"

module Decidim
  module System
    describe CreateDefaultContentBlocks do
      subject { described_class.new(organization) }

      let(:organization) { create(:organization) }

      it "creates and publishes all the default content blocks for an organization" do
        expect do
          described_class.new(organization).call
        end.to change { Decidim::ContentBlock.where(organization: organization).where.not(published_at: nil).count }.by(described_class::DEFAULT_CONTENT_BLOCKS.length)
      end
    end
  end
end
