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
end
