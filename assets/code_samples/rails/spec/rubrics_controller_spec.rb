require 'spec_helper'

describe RubricsController do  
  let(:rubric) { 
    mock_model(Rubric).tap do |rub|
      rub.stub(to_json: 'foo') 
    end
  }

  before do
    load_roles
    @creator = Fabricate :creator
    login_user @creator
    authorize_resource Rubric
    authorize_resource rubric
    Rubric.stub(:find) { rubric }
  end

  describe "#new" do
    it 'creates and redirects to edit' do
      Rubric.should_receive(:create!) { rubric }

      get :new
      response.should redirect_to(edit_rubric_path(rubric))
    end
  end

  describe "#destroy" do
    it 'destroys the rubric' do
      Rubric.should_receive(:find).with("14") { rubric }
      rubric.should_receive(:destroy)

      delete :destroy, id: 14
    end

    it 'redirects to rubrics index' do
      rubric.stub(:destroy)
      delete :destroy, id: 14
      response.should redirect_to(rubrics_path)
    end
  end

  describe "#index" do
    it "assigns all the rubrics" do
      Rubric.stub(:all) { :all_rubrics }

      get :index
      assigns[:rubrics].should == :all_rubrics
    end
  end

  describe "#edit" do
    it "assigns the rubric based on the id" do
      Rubric.should_receive(:find).with("44") { rubric }
      get :edit, {id: "44"}
      assigns[:rubric].should == rubric
    end

    it 'authorized the user for the rubric' do
      controller.should_receive(:authorize_user!).with(rubric)
      get :edit, {id: "12"}
    end
  end

  describe "#update" do
    before do
      Rubric.should_receive(:find).with("44") { rubric }
      authorize_resource rubric
      RubricManager.stub(:update)
    end

    it "redirects to index" do
      put :update, {id: "44", format: 'json'}
    end

    it "updates the attributes" do
      RubricManager.stub(:update).with('title' => "foopy")
      put :update, {id: "44", format: 'json', rubric: {'title' => "foopy"} }
      response.should redirect_to(rubrics_path)
    end

    it 'authorized the user for the rubric' do
      controller.should_receive(:authorize_user!).with(rubric)
      put :update, {id: "44"}
    end

  end
end

