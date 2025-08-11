# frozen_string_literal: true

require "spec_helper"

module Decidim
  module System
    describe CreateApiUser do
      subject { described_class.new(form, admin) }

      let(:command) { subject.call }
      let!(:organization) { create(:organization) }
      let(:admin) { create(:admin) }
      let(:valid) { true }
      let(:name) { "Dummy name" }
      let(:dummy_token) { SecureRandom.alphanumeric(32) }

      let(:form) do
        double(
          valid?: valid,
          organization: organization.id,
          name: name
        )
      end

      before do
        allow(SecureRandom).to receive(:alphanumeric).and_return(dummy_token)
      end

      it "creates the API user" do
        expect { command }.to change(Decidim::Api::ApiUser, :count).by(1)
      end

      it "broadcasts :ok with the generated token" do
        expect { command }.to broadcast(:ok) do |event_args|
          api_user, token = event_args
          expect(api_user).to be_an_instance_of(Decidim::Api::ApiUser)
          expect(token).to eq(dummy_token)
        end
      end

      context "when not valid" do
        let(:valid) { false }

        it "broadcasts invalid" do
          expect { command }.to broadcast(:invalid)
        end
      end
    end
  end
end
