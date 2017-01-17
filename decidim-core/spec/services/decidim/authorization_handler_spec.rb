# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe AuthorizationHandler do
    let(:handler) { described_class.new(params) }
    let(:params) { {} }

    describe "form_attributes" do
      subject { handler.form_attributes }

      it { is_expected.to match_array([:handler_name]) }
      it { is_expected.to_not match_array([:id, :user]) }
    end

    describe "to_partial_path" do
      subject { handler.to_partial_path }
      it { is_expected.to eq("decidim/authorization/form") }
    end

    describe "handler_name" do
      subject { handler.handler_name }
      it { is_expected.to eq("decidim/authorization_handler") }
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
        it { is_expected.to eq(nil) }
      end

      context "when the handler exists" do
        context "when the handler is not valid" do
          let(:name) { "decidim/authorization_handler" }
          it { is_expected.to eq(nil) }
        end

        context "when the handler is valid" do
          let(:name) { "decidim/dummy_authorization_handler" }

          context "when the handler is not configured" do
            before do
              Decidim.config.authorization_handlers = []
            end

            it { is_expected.to eq(nil) }
          end

          context "when the handler is configured" do
            it { is_expected.to be_kind_of(described_class) }
          end
        end
      end
    end

    describe "uniqueness" do
      let(:user) { create(:user) }

      before do
        subject.user = user
        allow(subject).to receive(:unique_id).and_return "foo"
        Decidim.authorization_handlers.push(described_class)
      end

      after do
        Decidim.authorization_handlers.delete(described_class)
      end

      context "when there's no other authorizations" do
        it "is valid if there's no authorization with the same id" do
          expect(subject).to be_valid
        end
      end

      context "when there's other authorizations" do
        let!(:other_user) { create(:user, organization: user.organization)}

        before do
          create(:authorization,
                 user: other_user,
                 unique_id: "foo",
                 name: handler.handler_name)
        end

        it "is invalid if there's another authorization with the same id" do
          expect(subject).to be_invalid
        end
      end
    end
  end
end
