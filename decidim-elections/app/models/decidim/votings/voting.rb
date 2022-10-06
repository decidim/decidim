# frozen_string_literal: true

module Decidim
  module Votings
    class Voting < ApplicationRecord
      include Traceable
      include Loggable
      include Decidim::Followable
      include Decidim::Participable
      include Decidim::ParticipatorySpaceResourceable
      include Decidim::Randomable
      include Decidim::Searchable
      include Decidim::TranslatableResource
      include Decidim::ScopableParticipatorySpace
      include Decidim::Publicable
      include Decidim::HasUploadValidations
      include Decidim::HasAttachments
      include Decidim::HasAttachmentCollections
      include Decidim::FilterableResource

      enum voting_type: [:in_person, :online, :hybrid].index_with(&:to_s), _suffix: :voting

      translatable_fields :title, :description

      belongs_to :organization,
                 foreign_key: "decidim_organization_id",
                 class_name: "Decidim::Organization"
      has_one :dataset,
              foreign_key: "decidim_votings_voting_id",
              class_name: "Decidim::Votings::Census::Dataset",
              dependent: :destroy
      has_many :components, as: :participatory_space, dependent: :destroy
      has_many :categories,
               foreign_key: "decidim_participatory_space_id",
               foreign_type: "decidim_participatory_space_type",
               dependent: :destroy,
               as: :participatory_space
      has_many :polling_stations, foreign_key: "decidim_votings_voting_id", class_name: "Decidim::Votings::PollingStation", inverse_of: :voting, dependent: :destroy
      has_many :polling_officers, foreign_key: "decidim_votings_voting_id", class_name: "Decidim::Votings::PollingOfficer", inverse_of: :voting, dependent: :destroy
      has_many :monitoring_committee_members,
               foreign_key: "decidim_votings_voting_id",
               class_name: "Decidim::Votings::MonitoringCommitteeMember",
               inverse_of: :voting,
               dependent: :destroy
      has_many :ballot_styles, foreign_key: "decidim_votings_voting_id", class_name: "Decidim::Votings::BallotStyle", inverse_of: :voting, dependent: :destroy

      validates :slug, uniqueness: { scope: :organization }
      validates :slug, presence: true, format: { with: Decidim::Votings::Voting.slug_format }

      has_one_attached :banner_image
      validates_upload :banner_image, uploader: Decidim::BannerImageUploader

      has_one_attached :introductory_image
      validates_upload :introductory_image, uploader: Decidim::BannerImageUploader

      scope :upcoming, -> { published.where("start_time > ?", Time.now.utc) }
      scope :active, lambda {
        published
          .where("start_time <= ?", Time.now.utc)
          .where("end_time >= ?", Time.now.utc)
      }
      scope :finished, -> { published.where("end_time < ?", Time.now.utc) }
      scope :order_by_most_recent, -> { order(created_at: :desc) }
      scope :promoted, -> { published.where(promoted: true) }

      scope_search_multi :with_any_date, [:active, :upcoming, :finished]

      def upcoming?
        start_time > Time.now.utc
      end

      def active?
        start_time <= Time.now.utc && end_time >= Time.now.utc
      end

      def finished?
        end_time < Time.now.utc
      end

      def period_status
        if finished?
          :finished
        elsif active?
          :ongoing
        else
          :upcoming
        end
      end

      searchable_fields({
                          scope_id: :decidim_scope_id,
                          participatory_space: :itself,
                          A: :title,
                          B: :description,
                          datetime: :published_at
                        },
                        index_on_create: ->(_voting) { false },
                        index_on_update: ->(voting) { voting.visible? })

      def self.log_presenter_class_for(_log)
        Decidim::Votings::AdminLog::VotingPresenter
      end

      # Allow ransacker to search for a key in a hstore column (`title`.`en`)
      ransacker :title do |parent|
        Arel::Nodes::InfixOperation.new("->>", parent.table[:title], Arel::Nodes.build_quoted(I18n.locale.to_s))
      end

      def to_param
        slug
      end

      def cta_button_text_key
        return :vote if published? && active?

        :more_info
      end

      def attachment_context
        :admin
      end

      def scopes_enabled
        true
      end

      def polling_stations_with_missing_officers?
        !online_voting? && polling_stations.any?(&:missing_officers?)
      end

      def available_polling_officers
        polling_officers
          .where(presided_polling_station_id: nil)
          .where(managed_polling_station_id: nil)
      end

      def has_ballot_styles?
        ballot_styles.exists?
      end

      def check_census_enabled?
        dataset.present? && show_check_census?
      end

      def elections
        Decidim::Elections::Election.where(component: components)
      end

      def published_elections
        Decidim::Elections::Election.where(component: components.published).published
      end

      # Methods for Votings Space <-> Elections Component interaction

      def complete_election_data(election, election_data)
        election_data[:polling_stations] = polling_stations.map(&:slug)
        election_data[:ballot_styles] = ballot_styles.map do |ballot_style|
          questions = ballot_style.questions_for(election)
          [ballot_style.slug, questions.map(&:slug)] if questions.any?
        end.compact.to_h
      end

      def vote_flow_for(election)
        Decidim::Votings::CensusVoteFlow.new(election)
      end

      # Create i18n ransackers for :title and :description.
      # Create the :search_text ransacker alias for searching from both of these.
      ransacker_i18n_multi :search_text, [:title, :description]

      def self.ransackable_scopes(_auth_object = nil)
        [:with_any_date]
      end
    end
  end
end
