class RubricComponentDescriptorManager
  class << self
    def build(descriptors)
      descriptors.map.with_index do |descriptor, idx|
        RubricComponentDescriptor.new(descriptor.merge(sequence: idx))
      end
    end
  end
end

