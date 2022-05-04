# frozen_string_literal: true

module Decidim
  # The data store for a Consultation in the Decidim::Consultations component.
  class Consultation < ApplicationRecord
    include Decidim::Participable
    include Decidim::Publicable
    include Decidim::Resourceable
    include Decidim::Consultations::PublicableResults
    include Decidim::Traceable
    include Decidim::Loggable
    include Decidim::ParticipatorySpaceResourceable
    include Decidim::Randomable
    include Decidim::Searchable
    include Decidim::HasUploadValidations
    include Decidim::TranslatableResource
    include Decidim::FilterableResource

    translatable_fields :title, :subtitle, :description

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"

    belongs_to :highlighted_scope,
               foreign_key: "decidim_highlighted_scope_id",
               class_name: "Decidim::Scope"

    has_many :questions,
             foreign_key: "decidim_consultation_id",
             class_name: "Decidim::Consultations::Question",
             inverse_of: :consultation,
             dependent: :destroy

    alias component_ids question_ids

    validates :slug, uniqueness: { scope: :organization }
    validates :slug, presence: true, format: { with: Decidim::Consultation.slug_format }

    has_one_attached :banner_image
    validates_upload :banner_image, uploader: Decidim::BannerImageUploader

    has_one_attached :introductory_image
    validates_upload :introductory_image, uploader: Decidim::BannerImageUploader

    scope :upcoming, -> { published.where("start_voting_date > ?", Time.now.utc) }
    scope :active, lambda {
      published
        .where("start_voting_date <= ?", Time.now.utc)
        .where("end_voting_date >= ?", Time.now.utc)
    }
    scope :finished, -> { published.where("end_voting_date < ?", Time.now.utc) }
    scope :order_by_most_recent, -> { order(created_at: :desc) }

    scope_search_multi :with_any_date, [:active, :upcoming, :finished]

    searchable_fields({
                        participatory_space: :itself,
                        A: :title,
                        B: :subtitle,
                        D: :description,
                        datetime: :published_at
                      },
                      index_on_create: ->(_process) { false },
                      index_on_update: ->(process) { process.visible? })

    def to_param
      slug
    end

    def upcoming?
      start_voting_date > Time.now.utc
    end

    def active?
      start_voting_date <= Time.now.utc && end_voting_date >= Time.now.utc
    end

    def finished?
      end_voting_date < Time.now.utc
    end

    def highlighted_questions
      questions.published.where(decidim_scope_id: decidim_highlighted_scope_id)
    end

    def questions_by_scope
      questions.published.group_by(&:scope)
    end

    def total_votes
      @total_votes ||= questions.published.sum(:votes_count)
    end

    def total_participants
      @total_participants ||= questions.published.joins(:votes).select(:decidim_author_id).distinct.count
    end

    # This method exists with the only purpose of getting rid of whats seems to be an issue in
    # the new scope picker: This engine is a bit special: consultations and questions are a kind of
    # nested participatory spaces. When a new question is created the consultation is the participatory space.
    # Since seems that the scope picker is asking to the current participatory space for its scope
    # this method is necessary to exist an return nil in order to be able to browse the scope hierarchy
    def scope
      nil
    end

    def closed?
      !active?
    end

    # Create i18n ransackers for :title, :subtitle and :description.
    # Create the :search_text ransacker alias for searching from all of these.
    ransacker_i18n_multi :search_text, [:title, :subtitle, :description]

    def self.ransackable_scopes(_auth_object = nil)
      [:with_any_date]
    end
  end
end
