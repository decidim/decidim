# frozen_string_literal: true

require "spec_helper"

# Specs in this file have access to a helper object that includes
# the NewslettersHelper. For example:
#
module Decidim
  describe NewslettersHelper do
    describe "#parse_interpolations" do
      describe "when the user is present" do
        subject { helper.parse_interpolations(text, user, newsletter.id) }

        let(:text) { %{(<p>Hello, %{name} <a href="https://google.com">Link</a></p>)} }
        let(:user) { create(:user, name: "User Name") }
        let(:organization) { create(:organization, host: "localhost") }
        let(:newsletter) { create(:newsletter) }

        it { is_expected.to eq(%{(<p>Hello, User Name <a href="https://google.com?utm_source=#{user.organization.host}&utm_campaign=newsletter_#{newsletter.id}">Link</a></p>)}) }
      end

      describe "when the user is not present" do
        subject { helper.parse_interpolations(text) }

        let(:text) { "<p>Hello, %{name}</p>" }

        it { is_expected.to eq("<p>Hello, </p>") }
      end
    end

    describe "#custom_url_for_mail_root" do
      let(:organization) { create(:organization) }

      describe "when newsletter present" do
        subject { helper.custom_url_for_mail_root(organization, newsletter.id) }

        let(:newsletter) { create(:newsletter) }

        it { is_expected.to eq(decidim.root_url(host: organization.host) + utm_codes(organization.host, newsletter.id.to_s)) }
      end

      describe "when newsletter not present" do
        subject { helper.custom_url_for_mail_root(organization) }

        it { is_expected.to eq(decidim.root_url(host: organization.host)) }
      end
    end
  end
end
