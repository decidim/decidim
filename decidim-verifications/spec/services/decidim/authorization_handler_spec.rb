# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AuthorizationHandler do
    let(:handler) { described_class.new(params) }
    let(:params) { {} }

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
