require 'spec_helper'

describe RubricComponentsController do  
  let(:rubric) { mock }
  let(:rubric_component) { mock(valid?: true) }

  before do
    load_roles
    @creator = Fabricate :creator
    login_user @creator
    authorize_resource rubric
    Rubric.stub(:find).with("3") { rubric }
  end

  describe '#destroy' do
    before do
      rubric.stub_chain(:rubric_components, :find).with("78") { rubric_component }
    end

    it "destroys the given assessment template question" do
      rubric_component.stub(to_json: {foo: "bar"}.to_json)
      rubric_component.should_receive(:destroy)
      delete :destroy, {format: :json, rubric_id: "3", id: "78"}
      response.body.should == {foo: "bar"}.to_json
    end
  end

  describe "#create" do
    before do
      @component = Fabricate :rubric_component
      RubricComponentManager.stub(:build).and_return(@component)
    end

    let(:rubric_component_params) { {'indicator' => 'yep'} }
    it 'create the rubric component' do
      RubricComponentManager.should_receive(:build).with(rubric, rubric_component_params).and_return(@component)

      post :create, {rubric_id: "3", rubric_component: rubric_component_params}
    end

    it 'returns the component json' do
      post :create, {format: :json, rubric_id: "3", rubric_component: rubric_component_params}
      response.body.should == @component.to_json
    end

    it 'authorizes for edit on the rubric' do
      controller.should_receive(:authorize!).with(:edit, rubric)
      post :create, {rubric_id: "3", rubric_component: rubric_component_params}
    end
  end

  describe "#update" do
    before do
      rubric.stub_chain(:rubric_components, :find).with("78") { rubric_component }
      RubricComponentManager.stub(:update).and_return(rubric_component)
    end

    let(:rubric_component_params) { {'indicator' => 'yep'} }

    it 'uses the RubricComponentManager to update the rubric' do
      RubricComponentManager.should_receive(:update).with(rubric_component, rubric_component_params)

      put :update, {id: "78", rubric_id: "3", rubric_component: rubric_component_params}
    end

    it 'renders the compoment' do
      rubric_component.stub(to_json: {foo: "bar"}.to_json)
      put :update, {format: :json, id: "78", rubric_id: "3", rubric_component: rubric_component_params}
      response.body.should == {foo: "bar"}.to_json
    end
  end
end
