# frozen_string_literal: true

require "spec_helper"

module Decidim::Elections
  describe TrusteeMailer, type: :mailer do
    let(:user) { create :user, :confirmed }
    let(:organization) { user.organization }
    let(:participatory_space) { create :participatory_process, organization: organization }

    let!(:trustee) do
      trustee = create(:trustee,
                       decidim_user_id: user.id)
      trustee.trustees_participatory_spaces.create(
        participatory_space: participatory_space
      )
    end

    describe "#notification" do
      subject(:mail) { described_class.notification(user, participatory_space, nil) }

      let(:translated_title) { translated(participatory_space.title, locale: organization.default_locale) }

      context "when using the organization default locale" do
        it "sends an email with the right subject" do
          expect(mail.subject).to include(translated_title)
        end

        it "sends an email with the right body" do
          expect(mail.body).to include(user.name)
        end
      end
    end
  end
end
