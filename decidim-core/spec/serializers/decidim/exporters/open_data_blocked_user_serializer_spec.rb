# frozen_string_literal: true

require "spec_helper"

module Decidim::Exporters
  describe OpenDataBlockedUserSerializer do
    subject { described_class.new(resource) }

    let(:organization) { create(:organization) }
    let(:serialized) { subject.serialize }

    describe "#serialize" do
      context "when the user has an associated block" do
        let!(:user_block) { create(:user_block, organization:) }
        let(:resource) { create(:user_moderation, user: user_block.user) }

        it "includes the block reasons" do
          expect(serialized).to include(block_reasons: user_block.justification)
        end

        it "includes the blocking user" do
          expect(serialized).to include(blocking_user: user_block.blocking_user.presenter.name)
        end
      end

      # The collection filters on `decidim_users.blocked_at`, but `blocking` is
      # resolved through `decidim_users.block_id`. Users blocked before #11235
      # have the former set and the latter still NULL, so the association
      # returns nil and the whole open data export used to abort here.
      context "when the user is blocked but has no associated block" do
        let(:user) { create(:user, :blocked, :confirmed, organization:) }
        let(:resource) { create(:user_moderation, user:) }

        before { user.update!(block_id: nil, blocked_at: Time.current) }

        it "does not raise" do
          expect { serialized }.not_to raise_error
        end

        it "serializes the block reasons as nil" do
          expect(serialized).to include(block_reasons: nil)
        end

        it "serializes the blocking user as nil" do
          expect(serialized).to include(blocking_user: nil)
        end

        it "still serializes the rest of the record" do
          expect(serialized).to include(user_id: user.id, about: user.about)
        end
      end
    end
  end
end
