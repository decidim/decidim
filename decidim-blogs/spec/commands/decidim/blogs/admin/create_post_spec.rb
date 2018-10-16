# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Blogs
    module Admin
      describe CreatePost do
        subject { described_class.new(form, current_user) }

        let(:organization) { create :organization }
        let(:participatory_process) { create :participatory_process, organization: organization }
        let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "blogs" }
        let(:current_user) { create :user, organization: organization }
        let(:title) { "Post title" }
        let(:body) { "Lorem Ipsum dolor sit amet" }

        let(:invalid) { false }
        let(:form) do
          double(
            invalid?: invalid,
            title: { en: title },
            body: { en: body },
            current_component: current_component,
            decidim_author_id: current_user.id
          )
        end

        context "when the form is not valid" do
          let(:invalid) { true }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when everything is ok" do
          let(:post) { Post.last }

          it "creates the post" do
            expect { subject.call }.to change(Post, :count).by(1)
          end

          it "sets the title" do
            subject.call
            expect(translated(post.title)).to eq title
          end

          it "sets the body" do
            subject.call
            expect(translated(post.body)).to eq body
          end

          it "sets the author" do
            subject.call
            expect(post.decidim_author_id).to eq current_user.id
          end

          it "sets the component" do
            subject.call
            expect(post.component).to eq current_component
          end

          it "broadcasts ok" do
            expect { subject.call }.to broadcast(:ok)
          end

          it "sends a notification to the participatory space followers" do
            follower = create(:user, organization: organization)
            create(:follow, followable: participatory_process, user: follower)

            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.blogs.post_created",
                event_class: Decidim::Blogs::CreatePostEvent,
                resource: kind_of(Post),
                recipient_ids: [follower.id]
              )

            subject.call
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:create!)
              .with(Post, current_user, kind_of(Hash), visibility: "all")
              .and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count)

            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
            expect(action_log.version.event).to eq "create"
          end
        end
      end
    end
  end
end
