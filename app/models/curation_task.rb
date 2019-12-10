class CurationTask < ApplicationRecord
  include PublicActivity::Common

  belongs_to :resource, polymorphic: true
  belongs_to :assignee, class_name: 'User', optional: true
  belongs_to :completed_by, class_name: 'User', optional: true

  STATUS = ['open', 'resolved']
  validates :status, inclusion: ['open', 'resolved']

  KEY = ['update', 'locate', 'review_suggestions','delete']
  validates :key, inclusion: ['update', 'locate', 'review_suggestions','delete'] # TODO: Come up with some more tasks

  serialize :update_fields
  
  PRIORITY = {
      low: -10,
      medium: 0,
      high: 10,
  }.freeze

  def self.open
    where(status: 'open')
  end

  def self.unassigned
    where(assignee_id: nil)
  end

  # All curation tasks assigned to the user, ordered by priority, then any unassigned tasks (also by priority)
  def self.queue_for_user(user)
    open.where(assignee_id: [user, nil]).order('assignee_id ASC, priority DESC')
  end

  def title
    "Task: #{I18n.t("curation_tasks.#{key}.title", type: resource_type.humanize.downcase)}"
  end

  def description
    I18n.t("curation_tasks.#{key}.description", type: resource_type.humanize.downcase)
  end

  def resolve(user = User.current_user)
    update_attributes(completed_by: user, status: 'resolved')
    create_activity(:resolve, owner: User.current_user, parameters: { logged_in_user_id: User.current_user.try(:id) })
  end

  def open?
    status == 'open'
  end

  def priority=(prio)
    super(prio.is_a?(Symbol) ? PRIORITY[prio] : prio)
  end

  def classify_priority
    if priority <= PRIORITY[:low]
      :low
    elsif priority >= PRIORITY[:high]
      :high
    else
      :medium
    end
  end
end
