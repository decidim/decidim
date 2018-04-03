# frozen_string_literal: true

require "spec_helper"
require "cancan/matchers"

describe Decidim::Initiatives::Abilities::Admin::AttachmentsAbility do
  subject { described_class.new(user, {}) }

  let(:organization) { create(:organization) }
  let(:initiative) { create(:initiative, organization: organization) }
  let(:attachment) { build(:attachment, :with_pdf, attached_to: initiative) }
  let(:other_initiative) { create(:initiative, organization: organization) }
  let(:other_attachment) { build(:attachment, :with_pdf, attached_to: other_initiative) }

  context "when read, update and destroy attachment" do
    context "and initiative author" do
      let(:user) { initiative.author }

      it "can perform actions on attachments" do
        expect(subject).to be_able_to(:read, attachment)
        expect(subject).to be_able_to(:update, attachment)
        expect(subject).to be_able_to(:destroy, attachment)
      end
    end

    context "and initiative committee members" do
      let(:user) { initiative.committee_members.approved.first.user }

      it "can perform actions on attachments" do
        expect(subject).to be_able_to(:read, attachment)
        expect(subject).to be_able_to(:update, attachment)
        expect(subject).to be_able_to(:destroy, attachment)
      end
    end

    context "and other initiative" do
      let(:user) { initiative.author }

      it "can not perform actions on attachments" do
        expect(subject).not_to be_able_to(:read, other_attachment)
        expect(subject).not_to be_able_to(:update, other_attachment)
        expect(subject).not_to be_able_to(:destroy, other_attachment)
      end
    end

    context "and plain users" do
      let(:user) { build(:user, organization: organization) }

      it "can not perform actions on attachments" do
        expect(subject).not_to be_able_to(:read, attachment)
        expect(subject).not_to be_able_to(:update, attachment)
        expect(subject).not_to be_able_to(:destroy, attachment)
      end
    end
  end

  context "when create attachment" do
    context "and initiative author" do
      let(:user) { initiative.author }

      it "can create attachment" do
        expect(subject).to be_able_to(:create, Decidim::Attachment)
      end
    end

    context "and initiative committee members" do
      let(:user) { initiative.committee_members.approved.first.user }

      it "can create attachment" do
        expect(subject).to be_able_to(:create, Decidim::Attachment)
      end
    end

    context "and plain users" do
      let(:user) { build(:user, organization: organization) }

      it "can not read attachment" do
        expect(subject).not_to be_able_to(:create, Decidim::Attachment)
      end
    end
  end
end
