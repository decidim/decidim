# frozen_string_literal: true

module Decidim
  module Initiatives
    module Abilities
      module Admin
        # Defines the abilities related to user able to administer attachments
        # for an initiative.
        # Intended to be used with `cancancan`.
        class AttachmentsAbility
          include CanCan::Ability

          attr_reader :user, :context

          def initialize(user, context)
            return unless user

            @user = user
            @context = context

            define_abilities
          end

          private

          def define_abilities
            return if user.admin?

            can :read, Decidim::Attachment do |attachment|
              attachment.attached_to.is_a?(Decidim::Initiative) &&
                attachment.attached_to.has_authorship?(user)
            end

            can :create, Decidim::Attachment if has_initiatives?(user)
            can :update, Decidim::Attachment do |attachment|
              attachment.attached_to.is_a?(Decidim::Initiative) &&
                attachment.attached_to.has_authorship?(user)
            end

            can :destroy, Decidim::Attachment do |attachment|
              attachment.attached_to.is_a?(Decidim::Initiative) &&
                attachment.attached_to.has_authorship?(user)
            end
          end

          def has_initiatives?(user)
            initiatives = InitiativesCreated.by(user) | InitiativesPromoted.by(user)
            initiatives.any?
          end
        end
      end
    end
  end
end
