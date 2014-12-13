class RubricsController < ApplicationController
  before_filter :find_and_authorize_rubric, only: [:edit, :update, :show, :destroy]

  def index
    @rubrics = Rubric.all
  end

  def new
    redirect_to edit_rubric_path(Rubric.create!)
  end

  def edit
  end

  def update
    RubricManager.update(@rubric, params[:rubric])
    redirect_to rubrics_path()
  end

  def destroy
    @rubric.destroy
    redirect_to rubrics_path
  end

  def show
  end

  private
  def find_and_authorize_rubric
    @rubric = Rubric.find(params[:id])
    authorize_user! @rubric
  end
end
