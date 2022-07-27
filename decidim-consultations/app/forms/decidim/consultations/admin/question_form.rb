# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # A form object used to create questions for a consultation from the admin dashboard.
      class QuestionForm < Form
        include TranslatableAttributes
        include Decidim::HasUploadValidations

        mimic :question

        translatable_attribute :title, String
        translatable_attribute :promoter_group, String
        translatable_attribute :participatory_scope, String
        translatable_attribute :question_context, String
        translatable_attribute :subtitle, String
        translatable_attribute :what_is_decided, String
        translatable_attribute :origin_scope, String
        translatable_attribute :origin_title, String
        attribute :origin_url, String
        attribute :slug, String
        attribute :remove_hero_image, Boolean, default: false
        attribute :hero_image
        attribute :banner_image
        attribute :remove_banner_image, Boolean, default: false
        attribute :hashtag, String
        attribute :decidim_scope_id, Integer
        attribute :external_voting, Boolean, default: false
        attribute :i_frame_url, String
        attribute :order, Integer

        validates :slug, presence: true, format: { with: Decidim::Consultations::Question.slug_format }
        validates :title, :promoter_group, :participatory_scope, :subtitle, :what_is_decided, translatable_presence: true
        validates :decidim_scope_id, presence: true
        validates :hero_image, passthru: { to: Decidim::Consultations::Question }
        validates :banner_image, passthru: { to: Decidim::Consultations::Question }
        validate :slug_uniqueness
        validates :origin_scope, :origin_title, translatable_presence: true, if: :has_origin_data?
        validates :i_frame_url, url: true, presence: true, if: :external_voting
        validates :order, numericality: { only_integer: true, allow_nil: true, allow_blank: true }

        alias organization current_organization

        private

        def slug_uniqueness
          return unless OrganizationQuestions
                        .new(current_organization)
                        .query
                        .where(slug:)
                        .where.not(id: context[:question_id]).any?

          errors.add(:slug, :taken)
        end

        def has_origin_data?
          has_value?(origin_title) || has_value?(origin_scope) || origin_url.present?
        end

        def has_value?(translatable_attribute)
          return false if translatable_attribute.nil?

          Decidim.available_locales.each do |locale|
            return true if translatable_attribute.with_indifferent_access[locale].present?
          end

          false
        end
      end
    end
  end
end
