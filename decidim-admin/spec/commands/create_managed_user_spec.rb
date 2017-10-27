# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe CreateManagedUser do
    describe "call" do
      let(:available_authorizations) { ["dummy_authorization_handler"] }
      let(:organization) { create(:organization, available_authorizations: available_authorizations) }
      let(:document_number) { "12345678X" }
      let(:form_params) do
        {
          name: "Foo",
          authorization: {
            handler_name: "dummy_authorization_handler",
            document_number: document_number
          }
        }
      end
      let(:form) do
        ManagedUserForm.from_params(
          form_params
        ).with_context(
          current_organization: organization
        )
      end
      let(:command) { described_class.new(form) }

      describe "when the form is not valid" do
        before do
          expect(form).to receive(:invalid?).and_return(true)
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "doesn't create a user" do
          expect do
            command.call
          end.not_to change { Decidim::User.count }
        end
      end

      describe "when the form is valid" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "creates a managed user" do
          expect do
            command.call
          end.to change { Decidim::User.count }.by(1)

          user = Decidim::User.last
          expect(user).to be_managed
        end

        it "authorizes the user" do
          expect(Decidim::Verifications::AuthorizeUser).to receive(:call).with(form.authorization)
          command.call
        end
      end
    end
  end
end
