# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module Census
      describe ExportMailer, type: :mailer do
        let(:voting) { create(:voting) }
        let(:user) { create(:user, organization: voting.organization) }

        describe "access codes export" do
          let(:filename) { "an_encrypted_zip_archive" }
          let(:password) { "secret" }
          let(:mail) { described_class.access_codes_export(user, voting, filename, password) }

          it "sets a subject" do
            expect(mail.subject).to include(translated(voting.title))
          end

          it "has a link" do
            expect(mail).to have_link("Download")
          end
        end
      end
    end
  end
end
