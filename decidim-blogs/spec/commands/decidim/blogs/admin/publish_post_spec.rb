# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Blogs
    module Admin
      describe PublishPost do
        subject { described_class.new(post, user) }

        let(:organization) { create(:organization, available_locales: [:en]) }
        let(:user) { create(:user, :admin, :confirmed, organization:) }
        let(:participatory_process) { create(:participatory_process, organization:) }
        let(:component) { create(:component, participatory_space: participatory_process, manifest_name: "blogs") }
        let!(:post) { create(:post, component:, published_at: nil) }

        context "when the post is already published" do
          let!(:post) { create(:post, :published, component:) }

          it "broadcasts :invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when everything is ok" do
          it "publishes the meeting" do
            subject.call
            post.reload
            expect(post).to be_published
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(:publish, post, user, visibility: "all")
              .and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
          end

          it "sends a notification to the participatory space followers" do
            follower = create(:user, organization:)
            create(:follow, followable: participatory_process, user: follower)

            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.blogs.post_created",
                event_class: Decidim::Blogs::CreatePostEvent,
                resource: kind_of(Post),
                followers: [follower]
              )
            expect { subject.call }.to broadcast(:ok)
          end
        end
      end
    end
  end
end
