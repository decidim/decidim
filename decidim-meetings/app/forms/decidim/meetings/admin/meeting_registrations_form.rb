# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This class holds a Form to update meeting registrations from Decidim's admin panel.
      class MeetingRegistrationsForm < Decidim::Form
        include TranslatableAttributes

        mimic :meeting

        attribute :registrations_enabled, Boolean
        attribute :registration_form_enabled, Boolean
        attribute :customize_registration_email, Boolean
        attribute :available_slots, Integer
        attribute :reserved_slots, Integer

        translatable_attribute :registration_terms, String
        translatable_attribute :registration_email_custom_content, String

        validates :registration_terms, translatable_presence: true, if: ->(form) { form.registrations_enabled? }
        validates :available_slots, :reserved_slots, presence: true, if: ->(form) { form.registrations_enabled? }
        validates :available_slots, numericality: { greater_than_or_equal_to: 0 }, if: ->(form) { form.registrations_enabled? && form.available_slots.present? }
        validates :reserved_slots, numericality: { greater_than_or_equal_to: 0 }, if: ->(form) { form.registrations_enabled? }
        validates :reserved_slots, numericality: { less_than_or_equal_to: :available_slots }, if: lambda { |form|
                                                                                                    form.registrations_enabled? &&
                                                                                                      form.reserved_slots.present? &&
                                                                                                      form.available_slots.present?
                                                                                                  }

        validate :available_slots_greater_than_or_equal_to_registrations_count, if: ->(form) { form.registrations_enabled? && form.available_slots.try(:positive?) }
        validate :reserved_slots_lower_than_or_equal_to_rest_available_slots_and_registrations_count, if: lambda { |form|
                                                                                                            form.registrations_enabled? &&
                                                                                                              form.reserved_slots.try(:positive?) &&
                                                                                                              form.available_slots.present?
                                                                                                          }

        # We need this method to ensure the form object will always have an ID,
        # and thus its `to_param` method will always return a significant value.
        # If we remove this method, get an error onn the `update` action and try
        # to resubmit the form, the form will not hold an ID, so the `to_param`
        # method will return an empty string and Rails will treat this as a
        # `create` action, thus raising an error since this action is not defined
        # for the controller we're using.
        #
        # TL;DR: if you remove this method, we'll get errors, so don't.
        def id
          return super if super.present?

          meeting.id
        end

        private

        def available_slots_greater_than_or_equal_to_registrations_count
          errors.add(:available_slots, :invalid) if available_slots < meeting.registrations.count
        end

        def reserved_slots_lower_than_or_equal_to_rest_available_slots_and_registrations_count
          total_slots = available_slots - meeting.registrations.count
          errors.add(:reserved_slots, I18n.t("decidim.meetings.admin.registrations.form.reserved_slots_less_than", count: total_slots)) if reserved_slots > total_slots
        end

        def meeting
          @meeting ||= context[:meeting]
        end
      end
    end
  end
end
