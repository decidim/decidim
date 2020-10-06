
module Decidim
  module Demographics
    # This class holds a Form to create/update meetings for Participants and UserGroups.
    class DemographicsForm < Decidim::Form
      attribute :gender, String
      attribute :age, String
      attribute :nationality, String
      attribute :postal_code, String
      attribute :background, String
    end
  end
end
