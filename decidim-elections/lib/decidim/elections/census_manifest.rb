# frozen_string_literal: true

module Decidim
  module Elections
    class CensusManifest
      include ActiveModel::Model
      include Decidim::AttributeObject::Model

      attribute :name, Symbol

      # If the census needs a form to be filled in the admin interface
      attribute :admin_form, String

      # The partial that will be rendered in the admin interface (mandatory if admin_form is set)
      attribute :admin_form_partial, String

      # The form that will be used to authenticate the voter prior to voting
      # This can be empty, in that case the voter will be authenticated using the current_user credentials
      # If set, the form be instantiated with the sent data and the election context
      # The form should inherit from Decidim::Form and implement the "valid?" method
      attribute :voter_form, String

      # The partial that will be rendered in the election booth to authenticate the voter (mandatory if voter_form is set)
      attribute :voter_form_partial, String

      # This command will be called after the census is updated in the admin interface
      # Receives the form and the election
      attribute :after_update_command, String

      # The presenter needs to defined the methods "identifier" and "created_date"
      # The default user presenter checks a few common methods to return a user identifier and date created.
      attribute :user_presenter, String, default: "Decidim::Elections::Censuses::UserPresenter"

      validates :name, presence: true
      validates :admin_form_partial, presence: true, if: -> { admin_form.present? }
      validates :voter_form_partial, presence: true, if: -> { voter_form.present? }

      def auth_form?
        voter_form.present?
      end

      def label
        I18n.t("decidim.elections.censuses.#{name}.label", default: name.to_s.humanize)
      end

      # Instead of individually defining "user_validator", "census_ready_validator", "census_counter" and "user_iterator",
      # if the user list can be obtained by a SQL query, a user_query can be specified and the rest of the methods will be defined automatically.
      # If used, the called block will receive the election object and should return an ActiveRecord::Relation
      def user_query(&block)
        @user_query = block
      end

      # Registers a block that will be used to generate a unique voter identifier
      # The block will receive the data of the voter and should return a unique identifier
      # If the block is not set, a default identifier will be generated based on the data
      def voter_uid(&block)
        @voter_uid = block
      end

      # a callback that will be called by the method "valid_user?"
      def user_validator(&block)
        @on_user_validation = block
      end

      # a callback that will be called by the method "census_ready?"
      def census_ready_validator(&block)
        @on_census_validation = block
      end

      # a callback that will be called by the method "count"
      def census_counter(&block)
        @on_census_count = block
      end

      # a callback that will be called by the method "users"
      def user_iterator(&block)
        @on_user_iteration = block
      end

      def form_instance(data = {}, context = {})
        form_class = voter_form.constantize
        form_class.from_params(data).with_context(context)
      end

      # validates the user using the Proc defined by user_validator
      # Receives the election object and user data (will depend on the census type))
      def valid_user?(election, data, context = {})
        if @on_user_validation
          @on_user_validation.call(election, data)
        elsif @user_query
          # If a user query is defined, we assume that the user is valid if it exists in the query
          if data.is_a?(Decidim::User)
            @user_query.call(election).exists?(id: data.id)
          elsif data.present?
            form_instance(data, context.merge(election:)).valid?
          end
        else
          false
        end
      end

      # validates the census using the Proc defined by census_ready_validator
      # Receives the election object
      def ready?(election)
        return false if election.census_manifest_changed? # needs to be persisted to be valid

        if @on_census_validation
          @on_census_validation.call(election)
        elsif @user_query
          # If a user query is defined, we assume that the census is ready if there are users in the query
          @user_query.call(election).exists?
        else
          false
        end
      end

      # returns the number of users in the census
      def count(election)
        if @on_census_count
          @on_census_count.call(election)
        elsif @user_query
          # If a user query is defined, we assume that the count is the number of users in the query
          @user_query.call(election).count
        end
      end

      def users(election, offset = 0, limit = 5)
        if @on_user_iteration
          @on_user_iteration.call(election, offset, limit)
        elsif @user_query
          # If a user query is defined, we assume that the users are the users in the query
          @user_query.call(election).offset(offset).limit(limit)
        else
          []
        end
      end

      # Generates a unique voter identifier based on the provided data
      def user_uid(data)
        if @voter_uid
          @voter_uid.call(data)
        elsif data.respond_to?(:to_global_id)
          # If the data is a Decidim::User or similar, we can use its global ID
          Digest::SHA256.hexdigest(data.to_global_id.to_s)
        else
          Digest::SHA256.hexdigest(data.to_s)
        end
      end
    end
  end
end
