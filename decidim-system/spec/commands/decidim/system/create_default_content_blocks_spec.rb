# frozen_string_literal: true

require "spec_helper"

module Decidim
  module System
    describe CreateDefaultContentBlocks do
      subject { described_class.new(organization) }

      let(:organization) { create(:organization) }
      let(:default_content_blocks) do
        Decidim.content_blocks.for(:homepage).select(&:default).length
      end

      it "creates and publishes all the default content blocks for an organization" do
        expect do
          described_class.new(organization).call
        end.to change { Decidim::ContentBlock.where(organization:).where.not(published_at: nil).count }.by(default_content_blocks)
      end
    end
  end
end
