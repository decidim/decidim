# frozen_string_literal: true

module Decidim
  # A command with all the business logic for when a user starts following a resource.
  class CreateFollow < Decidim::Command
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

      create_follow!
      increment_score

      broadcast(:ok, follow)
    end

    private

    attr_reader :follow, :form

    def create_follow!
      @follow = Follow.find_by(
        followable: form.followable,
        user: current_user
      ) || Follow.create!(
        followable: form.followable,
        user: current_user
      )
    end

    def increment_score
      return unless form.followable.is_a? Decidim::User

      Decidim::Gamification.increment_score(form.followable, :followers)
    end
  end
end
