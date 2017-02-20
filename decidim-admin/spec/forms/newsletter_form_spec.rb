# coding: utf-8
# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Admin
    describe NewsletterForm do
      let(:organization) { create(:organization) }
      let(:newsletter_subject) do
        {
          en: "Subject",
          es: "Asunto",
          ca: "Assumpte"
        }
      end

      let(:body) do
        {
          en: "Body",
          es: "Cuerpo",
          ca: "Cos"
        }
      end

      subject do
        described_class.new(subject: newsletter_subject, body: body).
          with_context(current_organization: organization)
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when there's no subject" do
        let(:newsletter_subject) { nil }

        it { is_expected.to be_invalid }
      end

      context "when there's no body" do
        let(:body) { nil }

        it { is_expected.to be_invalid }
      end
    end
  end
end
