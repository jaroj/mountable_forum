module SimpleForum
  class PostsController < ::SimpleForum::ApplicationController

    before_filter :authenticate_user, :except => [:index, :show]

    before_filter :find_forum
    before_filter :find_topic
    before_filter :find_post, :except => [:index, :new, :create, :preview]
    before_filter :build_post, :only => [:new, :create, :preview]
    before_filter :post_must_be_editable_by_authenticate_user, :only => [:edit, :update]

    def index

      respond_to do |format|
        format.html do
          redirect_to simple_forum.forum_topic_url(@forum, @topic), :status => :moved_permanently
        end
      end
    end

    def show

      respond_to do |format|
        format.html { redirect_to simple_forum.forum_topic_url(@forum, @topic, :page => @post.on_page, :anchor => "post-#{@post.id}") }
      end
    end

    def new
    end

    def create
      @success = @post.save

      respond_to do |format|
        format.html do
          if @success
            redirect_to simple_forum.forum_topic_url(@forum, @topic, :page => @post.on_page, :anchor => "post-#{@post.id}"),
                        :notice => t('simple_forum.controllers.posts.post_created')
          else
            redirect_to simple_forum.forum_topic_url(@forum, @topic, :page => @topic.last_page, :anchor => (@topic.recent_post ? "post-#{@topic.recent_post.id}" : nil)),
                        :alert => @post.errors.full_messages.join(', ')
          end
        end
        format.js
      end
    end

    def preview
      @post.created_at, @post.updated_at = Time.now

      respond_to do |format|
        format.js { render :partial => 'simple_forum/topics/post', :locals => {:post => @post, :preview => true} }
      end
    end

    def edit

      respond_to :html
    end

    def update
      @post.edited_by = authenticated_user
      @post.edited_at = Time.now
      @success = @post.editable_by?(authenticated_user, @forum.moderated_by?(authenticated_user)) ? @post.update_attributes(resource_params) : false

      respond_to do |format|
        format.html do
          if @success
            redirect_to simple_forum.forum_topic_url(@forum, @topic, :page => @post.on_page, :anchor => "post-#{@post.id}"),
                        :notice => t('simple_forum.controllers.posts.post_updated')
          else
            redirect_to :back, :alert => @post.errors.full_messages.join(', ')
          end
        end
        format.js
      end
    end


    def delete
      @success = @post.deletable_by?(authenticated_user, @forum.moderated_by?(authenticated_user)) ? @post.mark_as_deleted_by(authenticated_user) : false #check if post is deletable by authenticated_user in mark_as_deleted_by method

      respond_to do |format|
        format.html do
          if @success
            if Topic.exists?(@topic)
              redirect_to forum_topic_path(@forum, @topic), :notice => t('simple_forum.controllers.posts.post_deleted')
            else
              redirect_to forum_path(@forum), :notice => t('simple_forum.controllers.posts.post_deleted')
            end
          else
            redirect_to forum_topic_path(@forum, @topic), :alert => t('simple_forum.controllers.posts.post_cant_be_deleted')
          end
        end
        format.js
      end
    end

    private

    def find_forum
      @forum = SimpleForum::Forum.find params[:forum_id]
    end

    def find_topic
      @topic = @forum.topics.find params[:topic_id]
    end

    def find_post
      @post = @topic.posts.visible.find params[:id]
    end

    def build_post
      @post = @topic.posts.new resource_params do |post|
        post.user = authenticated_user
      end
    end

    def post_must_be_editable_by_authenticate_user
      redirect_to :back, :alert => t('simple_forum.controllers.posts.post_cant_be_edited') unless @post.editable_by?(authenticated_user, nil)
    end

    def resource_params
      unless p = params[:post].presence
        {}
      else
        p.permit(:body)
      end
    end

  end
end
