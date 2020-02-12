module CurationQueue
  extend ActiveSupport::Concern

  included do
    has_many :curation_tasks, as: :resource, inverse_of: :resource
    attr_writer :related_curation_task
    after_create :notify_curators, if: :user_requires_approval?
    after_save :update_curation_task, if: :was_curated?
    after_commit :notify_curators, on: :create, if: :user_requires_approval?
    if TeSS::Config.solr_enabled
      searchable do
        boolean :unverified do
          from_unverified_or_rejected?
        end
        boolean :shadowbanned do
          from_shadowbanned?
        end
      end
    end
  end

  class_methods do
    def from_verified_users
      joins(user: :role).where.not(users: { role_id: [Role.rejected.id, Role.unverified.id] })
    end
  end

  def user_requires_approval?
    user && user.has_role?('unverified_user') && (user.created_resources - [self]).none?
  end

  def notify_curators
    CurationMailer.user_requires_approval(self.user).deliver_later
  end

  def update_curation_task
    @related_curation_task.resolve
  end

  def was_curated?
    (defined? @related_curation_task) && !!@related_curation_task
  end

  def handle_edit_suggestion_destroy
    curation_tasks.open.where(key: 'review_suggestions').each(&:resolve)

  def from_unverified_or_rejected?
    user.has_role?(Role.rejected.name) || user.has_role?(Role.unverified.name)
  end

  def from_shadowbanned?
    user.shadowbanned?
  end
end
