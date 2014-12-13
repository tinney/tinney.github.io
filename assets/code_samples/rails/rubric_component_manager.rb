class RubricComponentManager
  class << self
    def build(rubric, args)
      descriptors = args.delete(:descriptors)
      rubric_descriptors = RubricComponentDescriptorManager.build(descriptors)
      rubric.rubric_components.create(args.merge(weight: 0, rubric_component_descriptors: rubric_descriptors))
    end

    def update(rubric_component, args)
      descriptors = args.delete(:descriptors)
      rubric_descriptors = RubricComponentDescriptorManager.build(descriptors)
      rubric_component.update_attributes(args.merge(rubric_component_descriptors: rubric_descriptors))
      rubric_component
    end
  end
end
