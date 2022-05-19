# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # This class holds a Form to create/update votings from Decidim's admin panel.
      class VotingForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :description, String
        attribute :slug, String
        attribute :start_time, Decidim::Attributes::TimeWithZone
        attribute :end_time, Decidim::Attributes::TimeWithZone
        attribute :scope_id, Integer
        attribute :promoted, Boolean
        attribute :remove_banner_image, Boolean, default: false
        attribute :banner_image
        attribute :remove_introductory_image, Boolean, default: false
        attribute :introductory_image
        attribute :voting_type, String
        attribute :census_contact_information, String
        attribute :show_check_census, Boolean, default: false

        validates :title, translatable_presence: true
        validates :description, translatable_presence: true
        validates :slug, presence: true, format: { with: Decidim::Votings::Voting.slug_format }
        validate :slug_uniqueness
        validates :start_time, presence: true, date: { before: :end_time }
        validates :end_time, presence: true, date: { after: :start_time }
        validates :banner_image, passthru: { to: Decidim::Votings::Voting }
        validates :introductory_image, passthru: { to: Decidim::Votings::Voting }
        validates :voting_type, presence: true, inclusion: { in: Votings::Voting.voting_types }

        validates :scope, presence: true, if: proc { |object| object.scope_id.present? }

        alias organization current_organization

        def map_model(model)
          self.scope_id = model.decidim_scope_id
        end

        def scope
          @scope ||= current_organization.scopes.find_by(id: scope_id)
        end

        def options_for_voting_type_select
          Voting.voting_types.map do |key, value|
            [
              I18n.t("voting_type.#{key}", scope: "decidim.votings.admin.votings.form"),
              value
            ]
          end
        end

        private

        def organization_votings
          Voting.where(organization: current_organization)
        end

        def slug_uniqueness
          return unless organization_votings
                        .where(slug: slug)
                        .where.not(id: context[:voting_id])
                        .any?

          errors.add(:slug, :taken)
        end
      end
    end
  end
end
