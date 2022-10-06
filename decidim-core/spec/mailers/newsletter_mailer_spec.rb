# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe NewsletterMailer, type: :mailer do
    let(:user) { create(:user, name: "Sarah Connor", organization:) }
    let(:newsletter) do
      create(:newsletter,
             organization:,
             subject: {
               en: "Email for %{name}",
               ca: "Email per %{name}",
               es: "Email para %{name}"
             },
             body: {
               en: "Content for %{name}",
               ca: "Contingut per %{name}",
               es: "Contenido para %{name}"
             })
    end

    let(:organization) { create(:organization) }

    describe "newsletter" do
      let(:mail) { described_class.newsletter(user, newsletter) }

      it "parses the subject" do
        expect(mail.subject).to eq("Email for Sarah Connor")
      end

      it "parses the body" do
        expect(email_body(mail)).to include("Content for Sarah Connor")
      end

      context "when the user has a different locale" do
        before do
          user.locale = "ca"
          user.save!
        end

        it "parses the subject in the user's locale" do
          expect(mail.subject).to eq("Email per Sarah Connor")
        end

        it "parses the body in the user's locale" do
          expect(email_body(mail)).to include("Contingut per Sarah Connor")
        end

        context "when there's no content in the user's locale" do
          let(:newsletter) do
            create(:newsletter,
                   organization:,
                   subject: {
                     en: "Email for %{name}",
                     ca: "",
                     es: "Email para %{name}"
                   },
                   body: {
                     en: "Content for %{name}",
                     ca: "",
                     es: "Contenido para %{name}"
                   })
          end

          it "fallbacks to the default one" do
            expect(mail.subject).to eq("Email for Sarah Connor")
            expect(email_body(mail)).to include("Content for Sarah Connor")
          end
        end
      end
    end
  end
end
