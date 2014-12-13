class RubricComponentsController < ApplicationController
  before_filter :find_and_authorize_rubric, only: [:create, :update, :destroy]
  wrap_parameters include: [:indicator, :descriptors]

  def create
    component = RubricComponentManager.build(@rubric, params[:rubric_component])
    respond_to do |format|
      if component.valid?
        format.json { render json: component.to_json }
      else
        render json: {errors: component.errors.full_messages}, status: :unprocessable_entity
      end
    end
  end

  def update
    @rubric_component = @rubric.rubric_components.find(params[:id])
    component = RubricComponentManager.update(@rubric_component, params[:rubric_component])

    respond_to do |format|
      format.json do 
        if component.valid?
          render json: component.to_json 
        else
          render json: {errors: component.errors.full_messages}, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @rubric_component = @rubric.rubric_components.find(params[:id])
    @rubric_component.destroy

    respond_to do |format|
      format.json { render json: @rubric_component.to_json }
    end
  end

  private
  def find_and_authorize_rubric
    @rubric = Rubric.find(params[:rubric_id])
    authorize! :edit, @rubric
  end
end
