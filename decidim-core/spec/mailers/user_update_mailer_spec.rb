# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UserUpdateMailer do
    let(:organization) { create(:organization, name: "Test Organization") }
    let(:user) { create(:user, :confirmed, organization:) }
    let(:updates) { %w(field1 field2 field3) }

    describe "#notify" do
      let(:mail) { described_class.notify(user, updates) }

      describe "email body" do
        it "includes user name" do
          expect(email_body(mail)).to include(user.name)
        end

        it "includes the updates list" do
          expect(email_body(mail)).to include("field1, field2 and field3")
        end

        it "includes organization name" do
          expect(email_body(mail)).to include("Test Organization")
        end
      end
    end
  end
end
