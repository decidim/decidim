
module Decidim
  module Demographics
    # This class holds a Form to create/update meetings for Participants and UserGroups.
    class DemographicsForm < Decidim::Form
      
      attribute :gender, String
      attribute :age, String
      attribute :nationalities, String
      attribute :postal_code, String
      attribute :background, String


      validates_presence_of :gender, :age, :nationalities
      validates :postal_code, format: { with: /\A[0-9]*\z/ }
      
    end
  end
end
