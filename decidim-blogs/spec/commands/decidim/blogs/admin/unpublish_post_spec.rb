# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Blogs
    module Admin
      describe UnpublishPost do
        subject { described_class.new(post, user) }

        let(:post) { create(:post, :published) }
        let(:user) { create(:user, :admin, :confirmed, organization: post.organization) }

        context "when the meeting is already unpublished" do
          let(:post) { create(:post) }

          it "broadcasts :invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when everything is ok" do
          it "unpublishes the post" do
            subject.call
            post.reload
            expect(post).not_to be_published
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(:unpublish, post, user, visibility: "all")
              .and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
          end
        end
      end
    end
  end
end
