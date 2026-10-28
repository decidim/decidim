# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UserBaseEntity do
    subject { user }

    let(:organization) { create(:organization) }
    let(:user) { build(:user, :confirmed, organization:) }

    describe "public followings" do
      let(:user_followed) { create(:user, :confirmed, organization: user.organization) }
      let(:public_resource) { create(:dummy_resource, :published) }
      let(:user_blocked) { create(:user, :confirmed, organization: user.organization, blocked: true) }

      before do
        user.save!
        create(:follow, user:, followable: user_followed)
        create(:follow, user:, followable: public_resource)
        create(:follow, user:, followable: user_blocked)
      end

      it "return all the things followed unless the blocked users" do
        expect(subject.public_followings).to contain_exactly(public_resource, user_followed)
      end
    end

    describe "#validates :name" do
      context "when name is John Doe" do
        let(:user) { build(:user, organization:, name: "John Doe") }

        it "is valid" do
          expect(user).to be_valid
        end
      end

      context "when name contains newlines" do
        let(:user) { build(:user, organization:, name: "John\n<script>alert('name')</script>") }

        it "is invalid" do
          expect(user).not_to be_valid
          expect(user.errors[:name]).to be_present
        end
      end

      context "when name contains carriage return" do
        let(:user) { build(:user, organization:, name: "John\r<script>alert('name')</script>") }

        it "is invalid" do
          expect(user).not_to be_valid
          expect(user.errors[:name]).to be_present
        end
      end
    end

    describe "#validates :nickname" do
      context "when nickname is john_doe" do
        let(:user) { build(:user, organization:, nickname: "john_doe") }

        it "is valid" do
          expect(user).to be_valid
        end
      end

      context "when nickname contains newlines" do
        let(:user) { build(:user, organization:, nickname: "john\n<script>alert('nickname')</script>") }

        it "is invalid" do
          expect(user).not_to be_valid
          expect(user.errors[:nickname]).to be_present
        end
      end

      context "when nickname contains carriage return" do
        let(:user) { build(:user, organization:, nickname: "john\r<script>alert('nickname')</script>") }

        it "is invalid" do
          expect(user).not_to be_valid
          expect(user.errors[:nickname]).to be_present
        end
      end
    end

    describe ".ransackable_attributes" do
      let(:admin) { build(:user, :admin, :confirmed, organization:) }

      context "when auth_object is an admin" do
        it "allows sorting/filtering by created_at" do
          expect(described_class.ransackable_attributes(admin)).to include("created_at")
        end

        it "allows sorting by role" do
          expect(described_class.ransackable_attributes(admin)).to include("role")
        end

        it "allows sorting by user_moderation_report_count" do
          expect(described_class.ransackable_attributes(admin)).to include("user_moderation_report_count")
        end
      end

      context "when auth_object is a regular user" do
        it "allows sorting/filtering by created_at" do
          expect(described_class.ransackable_attributes(user)).to include("created_at")
        end
      end
    end

    describe "reciprocal associations" do
      subject(:user_entity) { create(:user, :confirmed, organization:) }

      # The records related to `other_record` must not depend on `user_entity`, otherwise the
      # cascade under test would destroy them too.
      let(:other_user) { create(:user, :confirmed, organization:) }
      let(:third_user) { create(:user, :confirmed, organization:) }

      shared_examples "user entity reciprocal association" do |association, owner_name|
        before do
          record
          other_record
        end

        it "only includes the records of the user entity" do
          expect(Array(user_entity.public_send(association))).to contain_exactly(record)
        end

        it "does not include the records of another user entity" do
          expect(Array(user_entity.public_send(association))).not_to include(other_record)
        end

        it "points back to the user entity from the record" do
          expect(record.public_send(owner_name)).to eq(user_entity)
        end

        it "destroys the records when the user entity is destroyed" do
          user_entity.destroy

          expect(record.class.where(id: record.id)).to be_empty
          expect(other_record.class.where(id: other_record.id)).to exist
        end
      end

      context "with action logs" do
        let(:record) { create(:action_log, user: user_entity) }
        let(:other_record) { create(:action_log, user: other_user) }

        it_behaves_like "user entity reciprocal association", :action_logs, :user
      end

      context "with badge scores" do
        let(:record) { create(:badge_score, user: user_entity) }
        let(:other_record) { create(:badge_score, user: other_user) }

        it_behaves_like "user entity reciprocal association", :badge_scores, :user
      end

      context "with messages" do
        let(:conversation) { Decidim::Messaging::Conversation.start!(originator: user_entity, interlocutors: [third_user], body: "Hello") }
        let(:other_conversation) { Decidim::Messaging::Conversation.start!(originator: other_user, interlocutors: [third_user], body: "Hello") }

        let(:record) { conversation.messages.find_by!(sender: user_entity) }
        let(:other_record) { other_conversation.messages.find_by!(sender: other_user) }

        it_behaves_like "user entity reciprocal association", :messages, :sender
      end

      context "with participations" do
        let(:conversation) { Decidim::Messaging::Conversation.start!(originator: user_entity, interlocutors: [third_user], body: "Hello") }
        let(:other_conversation) { Decidim::Messaging::Conversation.start!(originator: other_user, interlocutors: [third_user], body: "Hello") }

        let(:record) { conversation.participations.find_by!(participant: user_entity) }
        let(:other_record) { other_conversation.participations.find_by!(participant: other_user) }

        it_behaves_like "user entity reciprocal association", :participations, :participant
      end

      context "with user moderations" do
        let(:record) { create(:user_moderation, user: user_entity) }
        let(:other_record) { create(:user_moderation, user: other_user) }

        it_behaves_like "user entity reciprocal association", :user_moderation, :user
      end
    end

    describe "sorting by report count" do
      subject(:sorter) { described_class.where(organization:).ransack({ s: "user_moderation_report_count asc" }, auth_object: admin) }

      let(:admin) { build(:user, :admin, :confirmed, organization:) }
      let!(:without_moderation) { create(:user, :confirmed, organization:) }
      let!(:with_few_reports) { create(:user, :confirmed, organization:) }
      let!(:with_many_reports) { create(:user, :confirmed, organization:) }

      before do
        create(:user_moderation, user: with_few_reports, report_count: 3)
        create(:user_moderation, user: with_many_reports, report_count: 9)
      end

      it "sorts users treating a missing moderation as zero reports" do
        expect(sorter.result.map(&:id)).to eq([without_moderation.id, with_few_reports.id, with_many_reports.id])
      end
    end
  end
end
