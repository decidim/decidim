# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AuthorizationHandler do
    let(:handler) { described_class.new(params) }
    let(:params) { {} }

    shared_context "with a duplicate authorization record" do
      let(:unique_id) { "12345678X" }
      let(:current_user) { create(:user) }
      let(:other_user) { create(:user, organization: current_user.organization) }
      let(:params) { { user: current_user } }
      let!(:duplicate) { create(:authorization, name: "authorization_handler", user: other_user, unique_id: unique_id) }

      before do
        allow(handler).to receive(:unique_id).and_return(unique_id)
      end
    end

    describe "form_attributes" do
      subject { handler.form_attributes }

      it { is_expected.to match_array(["handler_name"]) }
      it { is_expected.not_to match_array([:id, :user]) }
    end

    describe "to_partial_path" do
      subject { handler.to_partial_path }

      it { is_expected.to eq("authorization/form") }
    end

    describe "handler_name" do
      subject { handler.handler_name }

      it { is_expected.to eq("authorization_handler") }
    end

    describe "user" do
      subject { handler.user }

      let(:user) { instance_double(Decidim::User) }
      let(:params) { { user: user } }

      it { is_expected.to eq(user) }
    end

    describe "metadata" do
      subject { handler.metadata }

      it { is_expected.to be_kind_of(Hash) }
    end

    describe "#unique?" do
      subject { handler.unique? }

      it { is_expected.to be(true) }

      context "when a duplicate record exists" do
        include_context "with a duplicate authorization record"

        it { is_expected.to be(false) }
      end
    end

    describe "#transferrable?" do
      subject { handler.transferrable? }

      it { is_expected.to be(false) }

      context "when a duplicate record exists" do
        include_context "with a duplicate authorization record"

        it { is_expected.to be(false) }

        context "and the other user is deleted" do
          let(:other_user) { create(:user, :deleted, organization: current_user.organization) }

          it { is_expected.to be(true) }
        end
      end
    end

    describe "#duplicate" do
      subject { handler.duplicate }

      it { is_expected.to be_nil }

      context "when a duplicate record exists" do
        include_context "with a duplicate authorization record"

        it { is_expected.to eq(duplicate) }
      end
    end

    describe "handler_for" do
      subject { described_class.handler_for(name, params) }

      context "when the handler does not exist" do
        let(:name) { "decidim/foo" }

        it { is_expected.to be_nil }
      end

      context "when the handler exists" do
        context "when the handler is not valid" do
          let(:name) { "decidim/authorization_handler" }

          it { is_expected.to be_nil }
        end

        context "when the handler is valid" do
          let(:name) { "dummy_authorization_handler" }

          context "when the handler is not configured", with_authorization_workflows: [] do
            it { is_expected.to be_nil }
          end

          context "when the handler is configured" do
            it { is_expected.to be_kind_of(described_class) }
          end
        end
      end
    end
  end
end
