require 'spec_helper'

describe RubricComponentManager do
  subject { RubricComponentManager }

  describe '.build' do
    let(:rubric) { stub }
    let(:args) { { indicator: 'foo', descriptors: %w|alfa bravo| } }

    it 'creates a new RubricComponent and descriptors and adds it to the rubric' do
      rubric = Fabricate(:rubric)
      rubric.rubric_components.should == []
      args = {indicator: "Learn Math", descriptors: [{body: "a"}, {body: "b"}] }
      component = subject.build rubric, args
      rubric.reload.rubric_components.length.should == 1
      rubric.reload.rubric_components.should include(component)
      component.indicator.should == "Learn Math"
      component.rubric_component_descriptors.length.should == 2
      component.rubric_component_descriptors.map(&:body).should == ["a", "b"]
    end

    it "should not blow up if an invalid component is created" do
      rubric = Fabricate(:rubric)
      args = {indicator: nil, descriptors: []}
      component = subject.build rubric, args
      component.should_not be_valid 
    end
  end

  describe '.update' do
    it 'updates the indicator and descriptors' do
      component = Fabricate(:rubric_component)
      component_params = {
        indicator: "Knows stuff",
        weight: "2",
        descriptors: [{body: "hi"}, {body: "yerp"}, {body: "nope"}, {body: "bye"}]
      }

      subject.update(component, component_params)
      component.reload.indicator.should == "Knows stuff"
      component.rubric_component_descriptors.size.should == 4
      component.rubric_component_descriptors.map(&:body).should == %w(hi yerp nope bye)
    end

    it "should return an invalid component if it could not be updated" do
      component = Fabricate(:rubric_component)
      component_params = {
        indicator: nil,
        weight: "2",
        descriptors: [{body: "hi"}, {body: "yerp"}, {body: "nope"}, {body: "bye"}]
      }

      subject.update(component, component_params)
      component.should_not be_valid
    end
  end
end
  

