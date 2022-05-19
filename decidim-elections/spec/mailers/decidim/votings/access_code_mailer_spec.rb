# frozen_string_literal: true

require "spec_helper"

module Decidim::Votings
  describe AccessCodeMailer, type: :mailer do
    let!(:datum) { create :datum, :with_access_code }
    let!(:access_code) { datum.access_code }
    let!(:organization) { datum.dataset.voting.organization }
    let!(:voting) { datum.dataset.voting }
    let(:locale) { nil }

    describe "#send_access_code" do
      subject(:mail) { described_class.send_access_code(datum, locale) }

      let(:translated_title) { translated(voting.title, locale: locale || organization.default_locale) }

      context "when using the organization default locale" do
        let(:mail_subject) { "Your Access Code to participate in #{translated_title}" }
        let(:body) do
          ["Hello #{datum.full_name},",
           "Here is your Access Code that you asked for: #{access_code}. With this you will be able to participate in #{translated_title}."]
        end

        it "sends an email with the right subject" do
          expect(mail.subject).to eq(mail_subject)
        end

        it "sends an email with the right body" do
          body.each do |body_part|
            expect(mail.body.encoded).to include(body_part)
          end
        end
      end

      context "when setting a locale" do
        let(:locale) { "es" }
        let(:body) do
          ["Hola #{datum.full_name},"]
        end

        it "sends an email with the right body" do
          body.each do |body_part|
            expect(mail.body.encoded).to include(body_part)
          end
        end
      end
    end
  end
end
