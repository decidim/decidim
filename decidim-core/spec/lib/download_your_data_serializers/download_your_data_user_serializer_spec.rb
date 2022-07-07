# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DownloadYourDataSerializers::DownloadYourDataUserSerializer do
    subject { described_class.new(resource) }
    let(:resource) { create(:user) }

    let(:serialized) { subject.serialize }

    describe "#serialize" do
      it "includes the id" do
        expect(serialized).to include(id: resource.id)
      end

      it "includes the email" do
        expect(serialized).to include(email: resource.email)
      end

      it "includes the name" do
        expect(serialized).to include(name: resource.name)
      end

      it "includes the nickname" do
        expect(serialized).to include(nickname: resource.nickname)
      end

      it "includes the locale" do
        expect(serialized).to include(locale: resource.locale)
      end

      it "includes the organization" do
        expect(serialized[:organization]).to(
          include(id: resource.organization.id)
        )
        expect(serialized[:organization]).to(
          include(name: resource.organization.name)
        )
      end

      it "includes the newsletter notifications" do
        expect(serialized).to include(newsletter_notifications_at: resource.newsletter_notifications_at)
      end

      it "includes the email on notification" do
        expect(serialized).to include(notifications_sending_frequency: resource.notifications_sending_frequency)
      end

      it "includes the admin" do
        expect(serialized).to include(admin: resource.admin)
      end

      it "includes the personal url" do
        expect(serialized).to include(personal_url: resource.personal_url)
      end

      it "includes the about" do
        expect(serialized).to include(about: resource.about)
      end

      it "includes the invitation created at" do
        expect(serialized).to include(invitation_created_at: resource.invitation_created_at)
      end

      it "includes the invitation sent at" do
        expect(serialized).to include(invitation_sent_at: resource.invitation_sent_at)
      end

      it "includes the invitation accepted at" do
        expect(serialized).to include(invitation_accepted_at: resource.invitation_accepted_at)
      end

      it "includes the invited_by" do
        expect(serialized[:invited_by]).to(
          include(id: resource.invited_by_id)
        )
        expect(serialized[:invited_by]).to(
          include(type: resource.invited_by_type)
        )
      end

      it "includes the invitations count" do
        expect(serialized).to include(invitations_count: resource.invitations_count)
      end

      it "includes the reset password sent at" do
        expect(serialized).to include(reset_password_sent_at: resource.reset_password_sent_at)
      end

      it "includes the remember created at" do
        expect(serialized).to include(remember_created_at: resource.remember_created_at)
      end

      it "includes the sign in count" do
        expect(serialized).to include(sign_in_count: resource.sign_in_count)
      end

      it "includes the current sign in at" do
        expect(serialized).to include(current_sign_in_at: resource.current_sign_in_at)
      end

      it "includes the last sign in at" do
        expect(serialized).to include(last_sign_in_at: resource.last_sign_in_at)
      end

      it "includes the current sign in ip" do
        expect(serialized).to include(current_sign_in_ip: resource.current_sign_in_ip)
      end

      it "includes the last sign in ip" do
        expect(serialized).to include(last_sign_in_ip: resource.last_sign_in_ip)
      end

      it "includes the created at" do
        expect(serialized).to include(created_at: resource.created_at)
      end

      it "includes the updated at" do
        expect(serialized).to include(updated_at: resource.updated_at)
      end

      it "includes the confirmed at" do
        expect(serialized).to include(confirmed_at: resource.confirmed_at)
      end

      it "includes the confirmation sent at" do
        expect(serialized).to include(confirmation_sent_at: resource.confirmation_sent_at)
      end

      it "includes the unconfirmed email" do
        expect(serialized).to include(unconfirmed_email: resource.unconfirmed_email)
      end

      it "includes the delete reason" do
        expect(serialized).to include(delete_reason: resource.delete_reason)
      end

      it "includes the deleted at" do
        expect(serialized).to include(deleted_at: resource.deleted_at)
      end

      it "includes the managed" do
        expect(serialized).to include(managed: resource.managed)
      end

      it "includes the officialized at" do
        expect(serialized).to include(officialized_at: resource.officialized_at)
      end

      it "includes the officialized as" do
        expect(serialized).to include(officialized_as: resource.officialized_as)
      end
    end
  end
end
