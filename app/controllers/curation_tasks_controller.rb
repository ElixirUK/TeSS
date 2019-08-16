class CurationTasksController < ApplicationController
  before_action :check_curator
  before_action :set_curation_task, only: :show
  before_action :set_curation_tasks, only: [:show, :index]
  before_action :set_breadcrumbs

  def index
    redirect_to next_curation_tasks_path
  end

  def show
    render layout: 'full_width'
  end

  def new
    # 'authorize' needs to be called, so the 'policies' file is executed
    authorize CurationTask
    @curation_task = CurationTask.new
    @status = CurationTask.all.map { |c| [ c.status, c.id ] }
    @key = CurationTask.all.map { |c| [ c.key, c.id ] }
    @priority = CurationTask.all.map { |c| [ c.priority, c.id ] }
  end

  def create
    authorize CurationTask
    @curation_task = CurationTask.new(curation_task_params)
    #@curation_task.user = current_user

    respond_to do |format|
      if @curation_task.save
        @curation_task.create_activity :create, owner: current_user
        format.html { redirect_to @curation_task, notice: 'Curation Task was successfully created.' }
        format.json { render :show, status: :created, location: @curation_task }
      else
        format.html { render :new }
        format.json { render json: @curation_task.errors, status: :unprocessable_entity }
      end
    end
  end

  def next
    task = current_user.curation_task_queue.first
    if task
      redirect_to task
    else
      flash[:notice] = 'No more curation tasks remaining'
      redirect_to curation_tasks_path
    end
  end

  private

  def set_curation_task
    @curation_task = CurationTask.find_by_id(params[:id])
  end

  def set_curation_tasks
    # Sorting by `completed_by_id` puts unresolved tasks at the top!
    @curation_tasks = current_user.curation_task_queue
    @completed_curation_tasks = current_user.completed_curation_tasks.order('updated_at DESC').limit(5)
  end

  def check_curator
    unless current_user && (current_user.is_admin? || current_user.is_curator?)
      handle_error(:forbidden, 'This page is only visible to curators.')
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def curation_task_params
    # list all the possible inputs from the form
    permitted = [:status, :key, :priority, :resource_type, :resource_id]
    params.require(:curation_task).permit(permitted)
  end
end
