# frozen_string_literal: true

module Decidim
    module Assemblies
      module Admin
        # A command with all the business logic when updating assembly
        # settings in the system.
        class UpdateAssembliesSetting < Rectify::Command
          # Public: Initializes the command.
          #
          # assemblies_setting - A assemblies_setting object to update.
          # form - A form object with the params.
          def initialize(assemblies_setting, form)
            @assemblies_setting = assemblies_setting
            @form = form
          end
  
          # Executes the command. Broadcasts these events:
          #
          # - :ok when everything is valid.
          # - :invalid if the form wasn't valid and we couldn't proceed.
          #
          # Returns nothing.
          def call
            return broadcast(:invalid) if form.invalid?
  
            update_assemblies_setting!
  
            broadcast(:ok)
          end
  
          private
  
          attr_reader :form
  
          def update_assemblies_setting!
            Decidim.traceability.update!(
              @assemblies_setting,
              form.current_user,
              title: form.title
            )
          end
        end
      end
    end
  end
  