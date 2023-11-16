# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe PasswordsHelper do
    describe "#password_field_options_for" do
      subject { helper.password_field_options_for(user) }

      context "with :user" do
        let(:user) { :user }

        it "sets the correct minimum length" do
          expect(subject[:minlength]).to be(10)
        end

        it "sets the correct help text" do
          expect(subject[:help_text]).to eq(
            [
              "10 characters minimum,",
              "must not be too common (e.g. 123456)",
              "and must be different from your nickname and your email."
            ].join(" ")
          )
        end
      end

      context "with :admin" do
        let(:user) { :admin }

        it "sets the correct minimum length" do
          expect(subject[:minlength]).to be(15)
        end

        it "sets the correct help text" do
          expect(subject[:help_text]).to eq(
            [
              "15 characters minimum,",
              "must not be too common (e.g. 123456),",
              "must be different from your nickname and your email",
              "and must be different from your old passwords."
            ].join(" ")
          )
        end

        context "when the instance does not require strong admin passwords" do
          before do
            allow(Decidim.config).to receive(:admin_password_strong).and_return(false)
          end

          it "sets the correct minimum length" do
            expect(subject[:minlength]).to be(10)
          end

          it "sets the correct help text" do
            expect(subject[:help_text]).to eq(
              [
                "10 characters minimum,",
                "must not be too common (e.g. 123456)",
                "and must be different from your nickname and your email."
              ].join(" ")
            )
          end
        end
      end

      context "with string" do
        let(:user) { actual_user.send_reset_password_instructions }
        let(:actual_user) { create(:user) }

        it "fetches the user and returns the correct min length" do
          expect(subject[:minlength]).to be(10)
        end
      end

      context "with a User" do
        let(:user) { create(:user) }

        it "sets the correct minimum length" do
          expect(subject[:minlength]).to be(10)
        end
      end
    end
  end
end
