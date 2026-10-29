# frozen_string_literal: true

require "spec_helper"

describe "Decidim core association inverses" do # rubocop:disable RSpec/DescribeClass
  shared_examples "association with an explicit inverse_of" do |child_class, child_association, parent_class, parent_association|
    it "declares the inverse on both sides" do
      child_reflection = child_class.reflect_on_association(child_association)
      parent_reflection = parent_class.reflect_on_association(parent_association)

      expect(child_reflection.inverse_of).to eq(parent_reflection)
      expect(parent_reflection.inverse_of).to eq(child_reflection)
    end

    it "keeps the object identity when the child is read through the parent" do
      child

      loaded = Array(parent.public_send(parent_association)).find { |item| item.id == child.id }

      expect(loaded).to eq(child)
      expect(loaded.public_send(child_association)).to be(parent)
    end
  end

  describe "Decidim::Attachment <-> Decidim::AttachmentCollection" do
    let(:parent) { create(:attachment_collection) }
    let(:child) { create(:attachment, attachment_collection: parent) }

    it_behaves_like "association with an explicit inverse_of", Decidim::Attachment, :attachment_collection, Decidim::AttachmentCollection, :attachments
  end

  describe "Decidim::AuthorizationTransfer <-> Decidim::Authorization" do
    let(:parent) { create(:authorization) }
    let(:child) { create(:authorization_transfer, authorization: parent) }

    it_behaves_like "association with an explicit inverse_of", Decidim::AuthorizationTransfer, :authorization, Decidim::Authorization, :transfers
  end

  describe "Decidim::Categorization <-> Decidim::Category" do
    let(:parent) { create(:category) }
    let(:child) { Decidim::Categorization.create!(category: parent, categorizable: create(:dummy_resource, organization: parent.participatory_space.organization)) }

    it_behaves_like "association with an explicit inverse_of", Decidim::Categorization, :category, Decidim::Category, :categorizations
  end

  describe "Decidim::Follow <-> Decidim::UserBaseEntity" do
    let(:parent) { create(:user, :confirmed) }
    let(:child) { create(:follow, user: parent, followable: create(:dummy_resource, organization: parent.organization)) }

    it_behaves_like "association with an explicit inverse_of", Decidim::Follow, :user, Decidim::UserBaseEntity, :following_follows
  end

  describe "Decidim::Identity <-> Decidim::User" do
    let(:parent) { create(:user, :confirmed) }
    let(:child) { create(:identity, user: parent, organization: parent.organization) }

    it_behaves_like "association with an explicit inverse_of", Decidim::Identity, :user, Decidim::User, :identities
  end

  describe "Decidim::ImpersonationLog <-> Decidim::User" do
    let(:parent) { create(:user, :confirmed) }
    let(:child) { create(:impersonation_log, user: parent, admin: create(:user, :admin, :confirmed, organization: parent.organization)) }

    it_behaves_like "association with an explicit inverse_of", Decidim::ImpersonationLog, :user, Decidim::User, :impersonation_logs
  end

  describe "Decidim::Messaging::Message <-> Decidim::Messaging::Conversation" do
    let(:parent) { create(:conversation) }
    let(:child) { create(:message, conversation: parent) }

    it_behaves_like "association with an explicit inverse_of", Decidim::Messaging::Message, :conversation, Decidim::Messaging::Conversation, :messages
  end

  describe "Decidim::Messaging::Receipt <-> Decidim::Messaging::Message" do
    let(:parent) { create(:message, conversation: create(:conversation)) }
    let(:child) { Decidim::Messaging::Receipt.create!(recipient: parent.sender, message: parent) }

    it_behaves_like "association with an explicit inverse_of", Decidim::Messaging::Receipt, :message, Decidim::Messaging::Message, :receipts
  end

  describe "Decidim::Notification <-> Decidim::UserBaseEntity" do
    let(:parent) { create(:user, :confirmed) }
    let(:child) { create(:notification, user: parent, resource: create(:dummy_resource, organization: parent.organization)) }

    it_behaves_like "association with an explicit inverse_of", Decidim::Notification, :user, Decidim::UserBaseEntity, :notifications
  end

  describe "Decidim::Reminder <-> Decidim::User" do
    let(:parent) { create(:user, :confirmed) }
    let(:child) { create(:reminder, user: parent) }

    it_behaves_like "association with an explicit inverse_of", Decidim::Reminder, :user, Decidim::User, :reminders
  end

  describe "Decidim::ReminderDelivery <-> Decidim::Reminder" do
    let(:parent) { create(:reminder) }
    let(:child) { create(:reminder_delivery, reminder: parent) }

    it_behaves_like "association with an explicit inverse_of", Decidim::ReminderDelivery, :reminder, Decidim::Reminder, :deliveries
  end

  describe "Decidim::ReminderRecord <-> Decidim::Reminder" do
    let(:parent) { create(:reminder) }
    let(:child) { create(:reminder_record, reminder: parent) }

    it_behaves_like "association with an explicit inverse_of", Decidim::ReminderRecord, :reminder, Decidim::Reminder, :records
  end

  describe "Decidim::Report <-> Decidim::Moderation" do
    let(:parent) { create(:moderation) }
    let(:child) { create(:report, moderation: parent) }

    it_behaves_like "association with an explicit inverse_of", Decidim::Report, :moderation, Decidim::Moderation, :reports
  end

  describe "Decidim::StaticPage <-> Decidim::StaticPageTopic" do
    let(:parent) { create(:static_page_topic) }
    let(:child) { create(:static_page, topic: parent, organization: parent.organization) }

    it_behaves_like "association with an explicit inverse_of", Decidim::StaticPage, :topic, Decidim::StaticPageTopic, :pages
  end

  describe "Decidim::StaticPageTopic <-> Decidim::Organization" do
    let(:parent) { create(:organization) }
    let(:child) { create(:static_page_topic, organization: parent) }

    it_behaves_like "association with an explicit inverse_of", Decidim::StaticPageTopic, :organization, Decidim::Organization, :static_page_topics
  end

  describe "Decidim::UserBaseEntity <-> Decidim::Organization" do
    let(:parent) { create(:organization) }
    let(:child) { create(:user, :confirmed, organization: parent) }

    it_behaves_like "association with an explicit inverse_of", Decidim::UserBaseEntity, :organization, Decidim::Organization, :user_entities
  end

  describe "Decidim::UserReport <-> Decidim::UserModeration" do
    let(:parent) { create(:user_moderation) }
    let(:child) { create(:user_report, moderation: parent, user: parent.user) }

    it_behaves_like "association with an explicit inverse_of", Decidim::UserReport, :moderation, Decidim::UserModeration, :reports
  end

  # The associations that point to a class through a column the reciprocal does not use cannot have an
  # `inverse_of`: the collection on the other side is keyed on a different column, so declaring one would
  # link records that are not actually part of it. These stay on the reciprocity allow-list.
  describe "associations without a reciprocal keyed on the same column" do
    let(:organization) { create(:organization) }
    let(:admin) { create(:user, :admin, :confirmed, organization:) }
    let(:user) { create(:user, :confirmed, organization:) }

    it "keeps Decidim::ImpersonationLog#admin without an inverse_of" do
      reflection = Decidim::ImpersonationLog.reflect_on_association(:admin)

      expect(reflection.inverse_of).to be_nil
      expect(Decidim::User.reflect_on_association(:impersonation_logs).foreign_key).to eq("decidim_user_id")
    end

    it "keeps Decidim::UserBlock#blocking_user without an inverse_of" do
      reflection = Decidim::UserBlock.reflect_on_association(:blocking_user)

      expect(reflection.inverse_of).to be_nil
      expect(Decidim::UserBaseEntity.reflect_on_association(:blocking).foreign_key).to eq("id")
    end

    # `has_one :blocking` joins `decidim_user_blocks.id` to `decidim_users.block_id`, while `belongs_to :user`
    # joins `decidim_user_id`. Declaring the inverse on either side makes the block the in-memory target of the
    # has_one, and autosave then propagates `block_id` onto the block's primary key, so nulling `block_id` (the
    # admin unblock commands) saves the block as an insert with a NULL id.
    it "keeps Decidim::UserBlock#user without an inverse_of" do
      user = create(:user, :confirmed, organization:)
      block = create(:user_block, user:, organization:)

      expect(Decidim::UserBlock.reflect_on_association(:user).inverse_of).to be_nil
      expect(Decidim::UserBaseEntity.reflect_on_association(:blocking).inverse_of).to be_nil
      expect(user.association(:blocking).loaded?).to be false

      expect { user.update!(block_id: nil) }.not_to raise_error

      expect(user.block_id).to be_nil
      expect(Decidim::UserBlock.find(block.id)).to eq(block)
    end

    # `belongs_to :organization` is defined on `Decidim::UserBaseEntity` and a `belongs_to` can only have one
    # inverse, so `organization.users` cannot be the reciprocal of `user.organization`. `user_entities` is.
    it "keeps Decidim::User#organization with the user_entities inverse" do
      expect(Decidim::User.reflect_on_association(:organization).inverse_of)
        .to eq(Decidim::Organization.reflect_on_association(:user_entities))
    end
  end

  # These models declare `inverse_of` only on the reciprocal `has_many` side. Declaring it on the
  # `belongs_to` side propagates a child built through the parent into the parent's collection, where the
  # pending record is autosaved before its own save: for the messaging models that leaves
  # `decidim_conversation_id` NULL, and for `Decidim::AuthorizationTransferRecord` the record is already
  # persisted by the time its own save runs, which trips its `readonly?` guard. These stay on the
  # reciprocity allow-list.
  describe "associations whose inverse lives only on the has_many side" do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, :confirmed, organization:) }
    let(:other_user) { create(:user, :confirmed, organization:) }

    it "keeps Decidim::Messaging::Message#sender without an inverse_of" do
      expect(Decidim::Messaging::Message.reflect_on_association(:sender).inverse_of).to be_nil
      expect(Decidim::Messaging::Conversation.reflect_on_association(:messages).inverse_of)
        .to eq(Decidim::Messaging::Message.reflect_on_association(:conversation))
    end

    it "keeps Decidim::Messaging::Participation#participant without an inverse_of" do
      expect(Decidim::Messaging::Participation.reflect_on_association(:participant).inverse_of).to be_nil
      expect(Decidim::Messaging::Conversation.reflect_on_association(:participations).inverse_of)
        .to eq(Decidim::Messaging::Participation.reflect_on_association(:conversation))
    end

    it "keeps Decidim::Messaging::Receipt#recipient without an inverse_of" do
      expect(Decidim::Messaging::Receipt.reflect_on_association(:recipient).inverse_of).to be_nil
      expect(Decidim::Messaging::Message.reflect_on_association(:receipts).inverse_of)
        .to eq(Decidim::Messaging::Receipt.reflect_on_association(:message))
    end

    it "keeps Decidim::AuthorizationTransferRecord#transfer without an inverse_of" do
      expect(Decidim::AuthorizationTransferRecord.reflect_on_association(:transfer).inverse_of).to be_nil
      expect(Decidim::AuthorizationTransfer.reflect_on_association(:records).inverse_of)
        .to eq(Decidim::AuthorizationTransferRecord.reflect_on_association(:transfer))
    end

    it "saves a message built through the conversation with the conversation id" do
      conversation = create(:conversation, user:, originator: user, interlocutors: [other_user])
      message = conversation.messages.build(sender: user, body: "Hello")

      conversation.save!

      expect(message.decidim_conversation_id).to eq(conversation.id)
    end

    it "saves an authorization transfer record created through an unsaved transfer" do
      transfer = build(:authorization_transfer, organization:)
      record = build(:authorization_transfer_record, transfer:, resource: create(:dummy_resource, organization:))

      expect { record.save! }.not_to raise_error

      expect(record.transfer).to eq(transfer)
    end
  end
end
