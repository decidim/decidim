# frozen_string_literal: true

module Decidim
  # An authorization transfer object is created when the user authorizes
  # themselves with the same unique ID as some other user had used in the past.
  # Typically this can happen if the user first created an account and
  # authorized it, then deleted their account, and finally decided to register
  # again and authorize their account for a second time.
  #
  # To register an authorization transfer handler to handle the authorization
  # transfer handler in a specific module, use the following code example.
  #
  # @example Register authorization handler
  #   Decidim::AuthorizationTransfer.register(:my_module) do |transfer, auth_handler|
  #     # The move_records method updates the provided active record objects
  #     # to be mapped to the new user for which the authorization is being
  #     # transferred to. Provide the record class and the column name which
  #     # maps the user records to these records as its arguments.
  #     #
  #     # If you need access to the authorization handler that caused the
  #     # transfer to be initiated, it is available as the second yielded
  #     # argument (auth_hander).
  #     transfer.move_records(Decidim::MyModule::FooBar, :decidim_user_id)
  #   end
  #
  # The handler registration needs a name for the specific module handling the
  # transfer and a block which handles the specific transfer. The block is
  # called with the transfer record, i.e. instance of this class with access to
  # all necessary information required for handling the transfer.
  class AuthorizationTransfer < ApplicationRecord
    belongs_to :authorization, class_name: "Decidim::Authorization"
    belongs_to :user, class_name: "Decidim::User"
    belongs_to :source_user, class_name: "Decidim::User"
    has_many :records, class_name: "Decidim::AuthorizationTransferRecord", foreign_key: :transfer_id, dependent: :destroy

    class DisabledError < StandardError; end

    class << self
      # Provides access to the registry instance that stores the transfer
      # handlers for each module.
      #
      # The only reason for the registry is defined at the Decidim core module
      # is to have it in the `lib` folder which is not reloaded on every request
      # at the development environment. If the registry was stored within the
      # model class itself, it would be empty after every code reload (i.e.
      # every request).
      #
      # @return [Decidim::BlockRegistry] The registry of the authorization
      #   transfer handlers.
      def registry
        Decidim.authorization_transfer_registry
      end

      # Expose the methods provided by the registry singleton through the model
      # class.
      #
      # @!method register(name)
      # Registers an authorization transfer handler for a specific use case in
      # any modules that need to handle authorization transfers.
      # @example
      #   Decidim::AuthorizationTransfer.register(:my_module) do |transfer, auth_handler|
      #     transfer.move_records(Decidim::MyModule::FooBar, :decidim_user_id)
      #   end
      # @param name [Symbol] The name for the block, e.g. `:proposals`.
      # @yield [transfer, authorization_handler] Handles the authorization
      #   transfer for the given context. This is called before the
      #   authorization is transferred over to the new user and granted.
      # @yieldparam [Decidim::AuthorizationTransfer] The authorization transfer
      #   being processed which stores all the necessary information about the
      #   transfer, related authorization and related user and source user (i.e.
      #   the user from which the authorization is transferred from).
      # @yieldparam [Decidim::AuthorizationHandler] The authorization handler
      #   in charge of the current authorization action which initiated the
      #   transfer due to the duplicate unique ID it detected. This handler can
      #   provide access to the metadata from the new authorization action that
      #   caused the conflict to happen.
      # @return [Proc] The registered block itself.
      #
      # @!method unregister(name)
      # @see Decidim::BlockRegistry#unregister(name)
      #
      # @!method unregister(*names)
      # @see Decidim::BlockRegistry#unregister(*names)
      #
      # @!method registrations
      # @see Decidim::BlockRegistry#registrations
      delegate :register, :unregister, :registrations, to: :registry

      # Returns the enabled status for the authorization transfers. True by
      # default.
      #
      # @return [Boolean] True if the authorization transfers are enabled and
      #   false if they are disabled.
      def enabled?
        enable! if @enabled.nil?

        @enabled
      end

      # Enables the authorization transfer functionality. By default the
      # functionality is already enabled, so this method is only needed in case
      # the enabled state is changed e.g. during tests.
      #
      # @return [Boolean] Returns the enabled status after the enabling, i.e.
      #   true.
      def enable!
        @enabled = true
      end

      # Disables the authorization transfer functionality.
      #
      # @return [Boolean] Returns the enabled status after the disabling, i.e.
      #   false.
      def disable!
        @enabled = false
      end

      # Performs the authorization transfer for the provided authorization object
      # with the provided handler which is authorizing the user.
      #
      # @param authorization [Decidim::Authorization] The authorization object
      #   to be transferred over to the new user indicated by the authorization
      #   handler.
      # @param handler [Decidim::AuthorizationHandler] The authorization handler
      #   object with all the necessary information for authorizing the new
      #   user. The target user for which the authorization is transferred over
      #   to is fetched from the handler.
      # @raise [DisabledError] If the functionality is disabled.
      # @return [Decidim::AuthorizationTransfer] The created authorization
      #   transfer object.
      def perform!(authorization, handler)
        raise DisabledError unless enabled?

        transaction do
          transfer = create!(
            authorization:,
            user: handler.user,
            source_user: authorization.user
          )

          transfer.announce!(handler)

          # Update the metadata, transfer to the new user and grant.
          authorization.attributes = {
            metadata: handler.metadata,
            user: handler.user
          }

          authorization.grant!

          transfer
        end
      end
    end

    # Overwrites the method so that records cannot be modified.
    #
    # @return [Boolean] A boolean indicating whether the record is read only.
    def readonly?
      !new_record?
    end

    # This announces the transfer to external modules that can perform their own
    # actions during the authorization transfer. This is called before the
    # authorization is transferred to the new user allowing different modules to
    # transfer their records from the source user to the user that the
    # authorization is being transferred to. Note that during the publish event,
    # the authorization record is still pointing to the source user but the
    # transfer record itself available for the event is mapped correctly to the
    # target user.
    #
    # @param handler [Decidim::AuthorizationHandler] The authorization handler
    #   for the transfer procedure which contains all the necessary information
    #   about the data that was submitted from the authorization action. It is
    #   yielded to the registered transfer handlers as the second argument of
    #   the registered block.
    # @raise [DisabledError] If the functionality is disabled.
    # @return [Array<Proc>] An array of the blocks that were processed during
    #   the transfer.
    def announce!(handler)
      raise DisabledError unless self.class.enabled?

      self.class.registrations.values.each do |block|
        block.call(self, handler)
      end
    end

    # Creates a presenter instance for this record and returns it.
    #
    # @return [Decidim::AuthorizationTransferPresenter] The presenter object.
    def presenter
      AuthorizationTransferPresenter.new(self)
    end

    # Returns information about the transfer in the described format. The
    # returned hash contains information about the transferred records as the
    # record type (class name as string) as its keys and an informational hash
    # as its values with the following keys:
    # - :class - The class constant of the transferred records
    # - :count - Number of the records of this type that were transferred
    # - :name - An instance of ActiveModel::Name for the record class
    #
    # @example Format of the returned information hash
    #   {
    #     "Decidim::Foo" => {
    #        class: Decidim::Foo,
    #        count: 123,
    #        name: ActiveModel::Name.new(Decidim::Foo)
    #     },
    #     "Decidim::Bar" => {
    #        class: Decidim::Bar,
    #        count: 456,
    #        name: ActiveModel::Name.new(Decidim::Bar)
    #     }
    #   }
    #
    # @return [Hash<String => Hash<Symbol => Integer, ActiveModel::Name>>] The
    #   information hash created for the transfer.
    def information
      {}.tap do |types|
        records.find_each do |record|
          resource_class = record.type.safe_constantize
          next unless resource_class

          types[record.type] ||= { class: resource_class, count: 0 }
          types[record.type][:count] += 1
        end
      end
    end

    # Handles moving records from the source user to the user to which the
    # authorization is being transferred to. This updates the provided user
    # column of the provided class to the user being authorized.
    #
    # @param resource_class <Class> The resource class for which records should
    #   be transferred for.
    # @param user_column <Symbol, String> The User column to be updated for the
    #   records. It is updated with the user mapped to the transfer, i.e. the
    #   target user.
    # @return [Array<Decidim::AuthorizationTransferRecord>] An array of the
    #   created authorization transfer records.
    def move_records(resource_class, user_column)
      transferrable_records = resource_class.where(user_column => source_user_id)
      transferrable_ids = transferrable_records.pluck(:id)

      # rubocop:disable Rails::SkipsModelValidations
      transferrable_records.update_all(user_column => user_id)
      # rubocop:enable Rails::SkipsModelValidations

      records.create!(
        transferrable_ids.map do |resource_id|
          { resource_type: resource_class.name, resource_id: }
        end
      )
    end
  end
end
