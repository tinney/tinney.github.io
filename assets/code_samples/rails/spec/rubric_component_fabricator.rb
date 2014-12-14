Fabricator(:rubric_component) do
  weight 2
  indicator { Faker::Lorem.paragraph(2) }
  rubric_component_descriptors { (1..4).map { |idx| Fabricate(:rubric_component_descriptor, sequence: idx) } }
end
