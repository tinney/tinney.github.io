require 'spec_helper'

describe RubricComponentDescriptorManager do
  subject { RubricComponentDescriptorManager }

  describe '.build' do
    it 'creates new descriptors in order' do
      params = [
        {body: "alfa", short_description: "tango"}, 
        {body: "bravo", short_description: "foxtrot"}, 
        {body: "charlie", short_description: "donkey"}
      ]
      descriptors = subject.build params

      descriptors.should_not be_nil
      descriptors[0].sequence.should == 0
      descriptors[0].body.should == 'alfa'
      descriptors[0].short_description.should == 'tango'
      descriptors[1].sequence.should == 1
      descriptors[1].body.should == 'bravo'
      descriptors[1].short_description.should == 'foxtrot'
      descriptors[2].sequence.should == 2
      descriptors[2].body.should == 'charlie'
      descriptors[2].short_description.should == 'donkey'
    end
  end

  # describe '.update' do
  #   let(:component) { Fabricate(:rubric_component, rubric_component_descriptors: [ rcd1, rcd2, rcd3 ]) }

  #   let(:rcd1) { Fabricate(:rubric_component_descriptor, sequence: 1, body: 'alfa' ) }
  #   let(:rcd2) { Fabricate(:rubric_component_descriptor, sequence: 2, body: 'bravo') }
  #   let(:rcd3) { Fabricate(:rubric_component_descriptor, sequence: 3, body: 'charlie' ) }

  #   it 'updates existing descriptors' do
  #     subject.update(component, %w| first second third |)
  #     RubricComponentDescriptor.where(rubric_component_id: component.id).order(:sequence).map(&:body).should == %w|first second third|
  #   end

  #   it 'removes extra descriptors' do
  #     subject.update(component, %w| first second |)
  #     RubricComponentDescriptor.where(rubric_component_id: component.id).order(:sequence).map(&:body).should == %w|first second |
  #   end

  #   it 'adds new descriptors' do
  #     subject.update(component, %w| first second third fourth|)
  #     RubricComponentDescriptor.where(rubric_component_id: component.id).order(:sequence).map(&:body).should == %w|first second third fourth|
  #   end

  #   it 'filters blanks' do
  #     subject.update(component, ["first", "", "second", nil, "third", "\n\t"])
  #     RubricComponentDescriptor.where(rubric_component_id: component.id).order(:sequence).map(&:body).should == %w|first second third|
  #   end
  # end
end
