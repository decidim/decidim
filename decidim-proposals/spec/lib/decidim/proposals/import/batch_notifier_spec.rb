# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Import::BatchNotifier do
  subject(:notifier) { described_class.new(collection:, context:) }

  let(:recipient) { double("Decidim::User") }
  let(:followers_relation) { instance_double(ActiveRecord::Relation) }
  let(:participatory_space) { double("participatory_space", followers: followers_relation) }
  let(:imported_resource) { instance_double(Decidim::Proposals::Proposal, id: 101, participatory_space:) }
  let(:collection) { [imported_resource] }
  let(:context) { { import_creator_class: creator_class, current_participatory_space: participatory_space } }

  before do
    allow(followers_relation).to receive(:where).with(notification_types: %w(all followed-only)).and_return([recipient])
    allow(recipient).to receive(:deleted?).and_return(false)
    allow(recipient).to receive(:blocked?).and_return(false)
    allow(recipient).to receive(:is_a?).with(Decidim::User).and_return(true)
    allow(recipient).to receive(:id).and_return(123)
    allow(recipient).to receive(:notifications_sending_frequency).and_return("real_time")
  end

  describe "#notify!" do
    context "when creator class is ProposalCreator" do
      let(:creator_class) { Decidim::Proposals::Import::ProposalCreator }

      it "enqueues proposals imported email" do
        delivery = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
        allow(Decidim::Proposals::ImportMailer).to receive(:proposals_imported).and_return(delivery)

        notifier.notify!

        expect(Decidim::Proposals::ImportMailer).to have_received(:proposals_imported).once.with(collection, recipient)
        expect(delivery).to have_received(:deliver_later)
      end

      context "when recipient notifications are not real time" do
        before do
          allow(recipient).to receive(:notifications_sending_frequency).and_return("daily")
        end

        it "does not enqueue proposals imported email and creates one digest notification" do
          allow(Decidim::Proposals::ImportMailer).to receive(:proposals_imported)
          generator = instance_double(Decidim::NotificationGeneratorForRecipient, generate: true)
          allow(Decidim::NotificationGeneratorForRecipient).to receive(:new).and_return(generator)

          notifier.notify!

          expect(Decidim::Proposals::ImportMailer).not_to have_received(:proposals_imported)
          expect(Decidim::NotificationGeneratorForRecipient).to have_received(:new).with(
            "decidim.events.proposals.proposals_imported",
            Decidim::Proposals::ImportBatchEvent,
            imported_resource,
            recipient,
            :follower,
            { imported_count: collection.size }
          )
          expect(generator).to have_received(:generate)
        end
      end

      context "when creator class is provided as String" do
        let(:context) { { import_creator_class: "Decidim::Proposals::Import::ProposalCreator" } }

        it "delivers proposals imported email" do
          delivery = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
          allow(Decidim::Proposals::ImportMailer).to receive(:proposals_imported).and_return(delivery)

          notifier.notify!

          expect(Decidim::Proposals::ImportMailer).to have_received(:proposals_imported).with(collection, recipient)
          expect(delivery).to have_received(:deliver_later)
        end
      end
    end

    context "when creator class is ProposalAnswerCreator" do
      let(:creator_class) { Decidim::Proposals::Import::ProposalAnswerCreator }

      it "enqueues proposal answers imported email" do
        delivery = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
        allow(Decidim::Proposals::ImportMailer).to receive(:proposal_answers_imported).and_return(delivery)

        notifier.notify!

        expect(Decidim::Proposals::ImportMailer).to have_received(:proposal_answers_imported).with(collection, recipient)
        expect(delivery).to have_received(:deliver_later)
      end
    end

    context "when followers include non-user entries" do
      let(:creator_class) { Decidim::Proposals::Import::ProposalCreator }
      let(:non_user_recipient) { double("Decidim::UserGroup") }

      before do
        allow(non_user_recipient).to receive(:deleted?).and_return(false)
        allow(non_user_recipient).to receive(:blocked?).and_return(false)
        allow(non_user_recipient).to receive(:is_a?).with(Decidim::User).and_return(false)
        allow(followers_relation).to receive(:where).with(notification_types: %w(all followed-only)).and_return([recipient, non_user_recipient])
      end

      it "delivers only to valid users" do
        delivery = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
        allow(Decidim::Proposals::ImportMailer).to receive(:proposals_imported).and_return(delivery)

        notifier.notify!

        expect(Decidim::Proposals::ImportMailer).to have_received(:proposals_imported).once.with(collection, recipient)
      end
    end

    context "when importing multiple resources" do
      let(:creator_class) { Decidim::Proposals::Import::ProposalCreator }
      let(:other_followers_relation) { instance_double(ActiveRecord::Relation) }
      let(:other_participatory_space) { double("participatory_space", followers: other_followers_relation) }
      let(:other_imported_resource) { instance_double(Decidim::Proposals::Proposal, id: 102, participatory_space: other_participatory_space) }
      let(:collection) { [imported_resource, other_imported_resource] }

      before do
        allow(other_followers_relation).to receive(:where)
      end

      it "queries followers only once using the current participatory space" do
        delivery = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
        allow(Decidim::Proposals::ImportMailer).to receive(:proposals_imported).and_return(delivery)

        notifier.notify!

        expect(followers_relation).to have_received(:where).once.with(notification_types: %w(all followed-only))
        expect(other_followers_relation).not_to have_received(:where)
      end

      context "when recipient notifications are daily" do
        before do
          allow(recipient).to receive(:notifications_sending_frequency).and_return("daily")
        end

        it "creates one unified digest notification for the whole batch" do
          generator = instance_double(Decidim::NotificationGeneratorForRecipient, generate: true)
          allow(Decidim::NotificationGeneratorForRecipient).to receive(:new).and_return(generator)

          notifier.notify!

          expect(Decidim::NotificationGeneratorForRecipient).to have_received(:new).once.with(
            "decidim.events.proposals.proposals_imported",
            Decidim::Proposals::ImportBatchEvent,
            imported_resource,
            recipient,
            :follower,
            { imported_count: collection.size }
          )
          expect(generator).to have_received(:generate).once
        end
      end
    end

    context "when current participatory space is missing from context" do
      let(:creator_class) { Decidim::Proposals::Import::ProposalCreator }
      let(:context) { { import_creator_class: creator_class } }

      it "falls back to the first imported resource participatory space" do
        delivery = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
        allow(Decidim::Proposals::ImportMailer).to receive(:proposals_imported).and_return(delivery)

        notifier.notify!

        expect(followers_relation).to have_received(:where).once.with(notification_types: %w(all followed-only))
        expect(Decidim::Proposals::ImportMailer).to have_received(:proposals_imported).with(collection, recipient)
      end
    end
  end
end
