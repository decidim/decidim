# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Blogs
    module Admin
      describe CreatePost do
        subject { described_class.new(form, current_user) }

        let(:organization) { create :organization }
        let(:participatory_process) { create :participatory_process, organization: }
        let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "blogs" }
        let(:current_user) { create :user, organization: }
        let(:title) { "Post title" }
        let(:body) { "Lorem Ipsum dolor sit amet" }

        let(:invalid) { false }
        let(:form) do
          double(
            invalid?: invalid,
            title: { en: title },
            body: { en: body },
            current_component:,
            author: current_user
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

          it "creates a searchable resource" do
            expect { subject.call }.to change(Decidim::SearchableResource, :count).by_at_least(1)
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
            expect(post.author).to eq current_user
          end

          it "sets the component" do
            subject.call
            expect(post.component).to eq current_component
          end

          it "broadcasts ok" do
            expect { subject.call }.to broadcast(:ok)
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

          context "with a group author" do
            let(:group) { create(:user_group, :verified, organization:) }
            let(:form) do
              double(
                invalid?: invalid,
                title: { en: title },
                body: { en: body },
                current_component:,
                author: group
              )
            end

            it "sets the group as the author" do
              subject.call
              expect(post.author).to eq(group)
            end
          end
        end
      end
    end
  end
end
