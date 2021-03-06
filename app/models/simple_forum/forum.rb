module SimpleForum
  class Forum < ::ActiveRecord::Base
    #acts_as_nested_set

    has_many :topics,
             -> { order("#{SimpleForum::Topic.quoted_table_name}.last_updated_at DESC") },
             dependent: :destroy,
             class_name: "SimpleForum::Topic"

    belongs_to :recent_topic,
               class_name: 'SimpleForum::Topic'

    has_many :posts,
             -> { where(SimpleForum.show_deleted_posts ? ["1=1"] : ["#{SimpleForum::Post.quoted_table_name}.deleted_at IS NULL"]).order("#{SimpleForum::Post.quoted_table_name}.created_at DESC") },
             class_name: 'SimpleForum::Post'

    has_many :all_posts,
             -> { order("#{SimpleForum::Post.quoted_table_name}.created_at ASC") },
             class_name: "SimpleForum::Post",
             dependent: :delete_all

    belongs_to :recent_post,
               class_name: 'SimpleForum::Post'

    belongs_to :category,
               class_name: 'SimpleForum::Category'

    has_many :moderatorships,
             class_name: 'SimpleForum::Moderatorship'

    has_many :moderators,
             through: :moderatorships,
             source: :user

    scope :default_order, -> { order("#{quoted_table_name}.position ASC, #{quoted_table_name}.id ASC") }

    validates :name, presence: true
    validates :position, presence: true, numericality: {only_integer: true, allow_nil: true}

    #attr_accessible :name, :body, :parent_id, :position, :moderator_ids, :category_id, :is_topicable

    if respond_to?(:has_friendly_id)
      has_friendly_id :name, use_slug: true, approximate_ascii: true
    else
      def to_param
        "#{id}-#{name.to_s.parameterize}"
      end
    end

    def moderated_by?(user)
      return false unless user
      @moderated_by_cache ||= {}
      if @moderated_by_cache.has_key?(user.id)
        @moderated_by_cache[user.id]
      else
        @moderated_by_cache[user.id] = moderators.include?(user)
      end
    end

    alias_method :is_moderator?, :moderated_by?

  end
end
