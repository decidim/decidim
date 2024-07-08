# frozen_string_literal: true

module Decidim
  # A command with all the business logic for when a user stops following a resource.
  class DeleteFollow < Decidim::Command
    delegate :current_user, to: :form

    # Public: Initializes the command.
    #
    # form         - A form object with the params.
    def initialize(form)
      @form = form
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid, together with the follow.
    # - :invalid if the form was not valid and we could not proceed.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) if form.invalid?

      delete_follow!
      decrement_score

      broadcast(:ok)
    end

    private

    attr_reader :form

    def delete_follow!
      form.follow.destroy!
    end

    def decrement_score
      followable = form.follow.followable
      return unless followable.is_a? Decidim::User

      Decidim::Gamification.decrement_score(followable, :followers)
    end
  end
end
