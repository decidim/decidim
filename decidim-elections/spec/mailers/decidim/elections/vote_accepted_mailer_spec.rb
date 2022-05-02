# frozen_string_literal: true

require "spec_helper"

module Decidim::Elections
  describe VoteAcceptedMailer, type: :mailer do
    let(:vote) { create :vote }
    let(:verify_url) { "https://example.org/verify_url?hash=123" }
    let(:locale) { nil }
    let(:election) { vote.election }

    describe "#notification" do
      subject(:mail) { described_class.notification(vote, verify_url, locale) }

      let(:translated_title) { translated(election.title, locale: locale || election.component.organization.default_locale) }

      context "when using the organization default locale" do
        let(:mail_subject) { "Your vote for #{translated_title} was accepted." }
        let(:body) do
          ["<h2>Your vote for #{translated_title} was accepted.</h2>",
           "<p>Your vote was accepted! Using your voting token: #{vote.encrypted_vote_hash}, you can verify your vote <a href=\"#{verify_url}\">here</a>.</p>",
           "<p>You have received this notification because you&#39;ve voted for the #{translated_title} election.</p>"]
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
        let(:locale) { "ca" }
        let(:mail_subject) { "El teu vot a #{translated_title} s'ha acceptat." }
        let(:body) do
          ["<h2>El teu vot a #{translated_title} s&#39;ha acceptat.</h2>",
           "<p>El teu vot s'ha acceptat! Utilitzant el comprovant de vot: #{vote.encrypted_vote_hash}, pots verificar-lo <a href=\"#{verify_url}\">aquí</a>.</p>",
           "<p>Has rebut aquesta notificació perquè has votat a l&#39;elecció #{translated_title}.</p>"]
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
    end
  end
end
