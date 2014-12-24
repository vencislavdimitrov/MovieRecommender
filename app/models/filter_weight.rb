class FilterWeight < ActiveRecord::Base

  class << self
    def increment_trusted
      filter = FilterWeight.find_by_name 'trusted'
      filter.increment(:weight)
      filter.save
    end

    def increment_collaborative
      filter = FilterWeight.find_by_name 'collaborative'
      filter.increment(:weight)
      filter.save
    end

    def get_trusted_ratio
      trustedWeight = FilterWeight.find_by_name('trusted').weight
      collaborativeWeight = FilterWeight.find_by_name('collaborative').weight
      collaborativeWeight / trustedWeight
    end

    def get_collaborative_ratio
      trustedWeight = FilterWeight.find_by_name('trusted').weight
      collaborativeWeight = FilterWeight.find_by_name('collaborative').weight
      trustedWeight / collaborativeWeight
    end
  end
end
