# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe LikeResource do
    let(:resource) { create(:dummy_resource) }
    let!(:current_user) { create(:user, :confirmed, organization: resource.component.organization) }

    describe "User likes resource" do
      let(:command) { described_class.new(resource, current_user) }

      context "when in normal conditions" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "creates a new like for the resource" do
          expect do
            command.call
          end.to change(Like, :count).by(1)
        end

        it "notifies all followers of the liker that the resource has been liked" do
          follower = create(:user, organization: resource.organization)
          create(:follow, followable: current_user, user: follower)
          author_follower = create(:user, organization: resource.organization)
          create(:follow, followable: resource.author, user: author_follower)

          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.resource_liked",
              event_class: Decidim::ResourceLikedEvent,
              resource:,
              followers: [follower],
              extra: {
                liker_id: current_user.id
              }
            )

          command.call
        end
      end

      context "when the like is not valid" do
        before do
          resource.decidim_component_id = nil
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "does not create a new like for the resource" do
          expect do
            command.call
          end.not_to change(Like, :count)
        end
      end

      context "when the resource was previously liked and then unliked" do
        before do
          command.call
          Decidim::UnlikeResource.new(resource, current_user).call
        end

        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "does not raise ActiveRecord::RecordNotUnique" do
          expect { command.call }.not_to raise_error
        end

        it "restores the existing like instead of creating a new row" do
          expect { command.call }.not_to change(Like, :count)
          expect(Like.unscoped.where(resource:, decidim_author_id: current_user.id).count).to eq(1)
        end

        it "increases the likes_count back to 1" do
          expect do
            command.call
            resource.reload
          end.to change(resource, :likes_count).by(1)
        end

        it "notifies all followers of the liker that the resource has been liked again" do
          follower = create(:user, organization: resource.organization)
          create(:follow, followable: current_user, user: follower)

          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.resource_liked",
              event_class: Decidim::ResourceLikedEvent,
              resource:,
              followers: [follower],
              extra: {
                liker_id: current_user.id
              }
            )

          command.call
        end
      end
    end
  end
end
