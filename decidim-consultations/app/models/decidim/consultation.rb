# frozen_string_literal: true

module Decidim
  # The data store for a Consultation in the Decidim::Consultations component.
  class Consultation < ApplicationRecord
    include Decidim::Participable
    include Decidim::Publicable
    include Decidim::Consultations::PublicableResults

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

    validates :slug, uniqueness: { scope: :organization }
    validates :slug, presence: true, format: { with: Decidim::Consultation.slug_format }

    mount_uploader :banner_image, Decidim::BannerImageUploader
    mount_uploader :introductory_image, Decidim::BannerImageUploader

    scope :upcoming, -> { published.where("start_voting_date > ?", Time.now.utc) }
    scope :active, lambda {
      published
        .where("start_voting_date <= ?", Time.now.utc)
        .where("end_voting_date >= ?", Time.now.utc)
    }
    scope :finished, -> { published.where("end_voting_date < ?", Time.now.utc) }
    scope :order_by_most_recent, -> { order(created_at: :desc) }

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

    def regular_questions
      questions.published.where.not(decidim_scope_id: decidim_highlighted_scope_id).group_by(&:scope)
    end

    # This method exists with the only purpose of getting rid of whats seems to be an issue in
    # the new scope picker: This engine is a bit special: consultations and questions are a kind of
    # nested participatory spaces. When a new question is created the consultation is the participatory space.
    # Since seems that the scope picker is asking to the current participatory space for its scope
    # this method is necessary to exist an return nil in order to be able to browse the scope hierarchy
    def scope
      nil
    end

    def self.order_randomly(seed)
      transaction do
        connection.execute("SELECT setseed(#{connection.quote(seed)})")
        select('"decidim_consultations".*, RANDOM()').order(Arel.sql("RANDOM()")).load
      end
    end
  end
end
