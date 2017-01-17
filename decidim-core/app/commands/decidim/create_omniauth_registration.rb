# frozen_string_literal: true
module Decidim
  class CreateOmniauthRegistration < Rectify::Command
    # Public: Initializes the command.
    #
    # form - A form object with the params.
    def initialize(form)
      @form = form
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the form wasn't valid and we couldn't proceed.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) if form.invalid?

      create_user
      create_identity

      broadcast(:ok, @user)
    end

    private

    attr_reader :form

    def create_user
      generated_password = SecureRandom.hex

      @user = User.create!({
        email: @form.email,
        name: @form.name,
        password: generated_password,
        password_confirmation: generated_password,
        organization: @form.current_organization,
        tos_agreement: @form.tos_agreement
      })
    end

    def create_identity
      @user.identities.create!({
        provider: @form.provider,
        uid: @form.uid
      })
    end
  end
end
# Class: Find or create a user from a omniauth hash.
#
# omniauth_hash - A Hash that represents the omniauth data. See
#                 https://github.com/omniauth/omniauth/wiki/Auth-Hash-Schema
#                 for more information.
# organization  - A Decidim::Organization object
#
# Returns a Decidim::User object
# def self.find_or_create_from_oauth(omniauth_hash, organization)
#   omniauth_hash = omniauth_hash.with_indifferent_access
#   identity = Identity.where(provider: omniauth_hash[:provider], uid: omniauth_hash[:uid]).first

#   if identity.present?
#     identity.user
#   else
#     info = omniauth_hash[:info]
#     generated_password = SecureRandom.hex

#     user = User.create(email: info[:email],
#                        name: info[:name],
#                        password: generated_password,
#                        password_confirmation: generated_password,
#                        organization: organization,
#                        tos_agreement: true)

#     if user.valid?
#       user.identities.create(provider: omniauth_hash[:provider], uid: omniauth_hash[:uid])
#       user.skip_confirmation! if info[:verified]
#     end

#     user
#   end
# end

    # describe ".find_or_create_from_oauth" do
    #   let(:verified) { true }
    #   let(:email) { "user@from-facebook.com"}
    #   let(:omniauth_hash) {
    #     {
    #       provider: 'facebook',
    #       uid: '123545',
    #       info: {
    #         email: "user@from-facebook.com",
    #         name: "Facebook User",
    #         verified: verified
    #       }
    #     }
    #   }
      
    #   context "when a user with the same email doesn't exists" do
    #     context "and the email is verified" do
    #       it "creates a confirmed user" do
    #         user = User.find_or_create_from_oauth(omniauth_hash, organization)
    #         expect(user).to be_persisted
    #         expect(user).to be_confirmed
    #       end
    #     end

    #     context "and the email is not verified" do
    #       let(:verified) { false }
          
    #       it "doesn't confirm the user" do
    #         user = User.find_or_create_from_oauth(omniauth_hash, organization)
    #         expect(user).to be_persisted
    #         expect(user).not_to be_confirmed
    #       end
    #     end
    #   end

    #   context "when a user with the same email exists" do
    #     it "doesn't create the user" do
    #       create(:user, organization: organization, email: email)

    #       expect {
    #         user = User.find_or_create_from_oauth(omniauth_hash, organization)
    #       }.not_to change {
    #         User.count
    #       }
    #     end
    #   end