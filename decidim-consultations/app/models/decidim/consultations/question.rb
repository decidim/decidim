# frozen_string_literal: true

module Decidim
  module Consultations
    # The data store for Consultation questions in the Decidim::Consultations component.
    class Question < ApplicationRecord
      include Decidim::HasResourcePermission
      include Decidim::Participable
      include Decidim::Publicable
      include Decidim::ScopableParticipatorySpace
      include Decidim::Comments::Commentable
      include Decidim::Followable
      include Decidim::HasAttachments
      include Decidim::HasAttachmentCollections
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::ParticipatorySpaceResourceable
      include Decidim::Randomable

      belongs_to :consultation,
                 foreign_key: "decidim_consultation_id",
                 class_name: "Decidim::Consultation",
                 inverse_of: :questions

      belongs_to :organization,
                 foreign_key: "decidim_organization_id",
                 class_name: "Decidim::Organization"

      has_many :components, as: :participatory_space, dependent: :destroy
      has_many :votes,
               foreign_key: "decidim_consultation_question_id",
               class_name: "Decidim::Consultations::Vote",
               dependent: :destroy,
               inverse_of: :question

      has_many :responses,
               foreign_key: "decidim_consultations_questions_id",
               class_name: "Decidim::Consultations::Response",
               inverse_of: :question,
               dependent: :destroy

      has_many :response_groups,
               foreign_key: "decidim_consultations_questions_id",
               class_name: "Decidim::Consultations::ResponseGroup",
               inverse_of: :question,
               dependent: :destroy

      has_many :categories,
               foreign_key: "decidim_participatory_space_id",
               foreign_type: "decidim_participatory_space_type",
               dependent: :destroy,
               as: :participatory_space

      mount_uploader :hero_image, Decidim::HeroImageUploader
      mount_uploader :banner_image, Decidim::BannerImageUploader

      default_scope { order(order: :asc) }

      delegate :start_voting_date, to: :consultation
      delegate :end_voting_date, to: :consultation
      delegate :results_published?, to: :consultation

      alias participatory_space consultation

      # Sorted results for the given question.
      def sorted_results
        responses.order(votes_count: :desc)
      end

      # if results can be shown to admins
      def publishable_results?
        consultation.finished? && sorted_results.any?
      end

      def most_voted_response
        @most_voted_response ||= responses.order(votes_count: :desc).first
      end

      # Total number of votes, on multiple votes questions does not match users voting
      def total_votes
        @total_votes ||= responses.sum(&:votes_count)
      end

      # Total number of users voting
      def total_participants
        @total_participants ||= votes.select(:decidim_author_id).distinct.count
      end

      # Multiple answers allowed?
      def multiple?
        return false if external_voting
        return false if max_votes.blank?

        max_votes > 1
      end

      # Sorted responses by date so admins have a way to predict it
      def sorted_responses
        @sorted_responses ||= responses.sort_by(&:created_at)
      end

      # matrix of responses by group (sorted by configuration)
      def grouped_responses
        @grouped_responses ||= sorted_responses.group_by(&:response_group)
      end

      def grouped?
        return false unless multiple?

        response_groups_count.positive?
      end

      # Public: Overrides the `comments_have_alignment?` Commentable concern method.
      def comments_have_alignment?
        true
      end

      # Public: Overrides the `comments_have_votes?` Commentable concern method.
      def comments_have_votes?
        true
      end

      def hashtag
        attributes["hashtag"].to_s.delete("#")
      end

      def banner_image_url
        banner_image.present? ? banner_image.url : consultation.banner_image.url
      end

      # Public: Check if the user has voted the question.
      #
      # Returns Boolean.
      def voted_by?(user)
        votes.where(author: user).any?
      end

      # Public: Checks whether the given user can unvote the question or note.
      #
      # Returns a Boolean.
      def can_be_unvoted_by?(user)
        consultation.active? &&
          consultation.published? &&
          published? &&
          voted_by?(user)
      end

      # Public: Checks whether the given user can vote the question or note.
      #
      # Returns a Boolean.
      def can_be_voted_by?(user)
        organization.id == user.organization.id &&
          consultation.active? &&
          consultation.published? &&
          published? &&
          !voted_by?(user)
      end

      def scopes_enabled?
        false
      end

      def scopes_enabled
        false
      end

      def to_param
        slug
      end

      # Overrides module name from participable concern
      def module_name
        "Decidim::Consultations"
      end

      def mounted_engine
        "decidim_consultations"
      end

      def mounted_admin_engine
        "decidim_admin_consultations"
      end

      def self.participatory_space_manifest
        Decidim.find_participatory_space_manifest(Decidim::Consultation.name.demodulize.underscore.pluralize)
      end

      def resource_description
        subtitle
      end

      # Public: Overrides the `allow_resource_permissions?` Resourceable concern method.
      def allow_resource_permissions?
        true
      end
    end
  end
end
