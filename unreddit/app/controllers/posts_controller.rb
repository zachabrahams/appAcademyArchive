class PostsController < ApplicationController

  before_action :require_author, only: [:edit, :update]

  def new
    @the_url = posts_url
    @post = Post.new
    render :new
  end

  def create
    @post = current_user.posts.new(post_params)
    if @post.save
      flash[:notice] = "Post created."
      redirect_to post_url(@post)
    else
      flash.now[:errors] = @post.errors.full_messages
      render :new
    end
  end

  def show
    @post = Post.find(params[:id])
    @comments = @post.comments
    @comments_hash = @post.comments_by_parent_id
    render :show
  end

  def edit
    @post = Post.find(params[:id])
    @the_url = post_url(@post)
    render :edit
  end

  def update
    @post = Post.find(params[:id])
    if @post.update(post_params)
      flash[:notice] = "Post updated."
      redirect_to post_url(@post)
    else
      flash.now[:errors] = @post.errors.full_messages
      render :edit
    end
  end

  def upvote
    @post = Post.find(params[:id])
    @vote = Vote.new(value: 1, votable_id: @post.id, votable_type: "Post" )
    @vote.save
    redirect_to request.referer
  end

  def downvote
    @post = Post.find(params[:id])
    @vote = Vote.new(value: -1, votable_id: @post.id, votable_type: "Post" )
    @vote.save
    redirect_to request.referer
  end

  private

  def post_params
    params.require(:post).permit(:title, :url, :content, sub_ids: [])
  end

  def require_author
    unless current_user.id == Post.find(params[:id]).author_id
      redirect_to :forbidden
    end
  end

end
