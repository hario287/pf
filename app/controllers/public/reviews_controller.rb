class Public::ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: [:edit, :update, :destroy]

  def show
    @review = Review.find(params[:id])
    # @user = @review.user
    @review_comment = ReviewComment.new

  end

  def create
    @review = Review.new(review_params)
    @review.user_id = current_user.id
    tag_list = params[:review][:tag_name].split(',')
    if @review.save
      @review.save_tag(tag_list)
      redirect_to review_path(@review), notice: "投稿しました。"
    else
      @reviews = Review.all
      render 'index'
    end
  end

  def index
    if params[:sort] == nil
      to = Time.current.at_end_of_day
      from = to - 1.week
      @reviews = Review.includes(:favorites).sort {
        |a,b| b.favorites.where(created_at: from..to).size <=>
        a.favorites.where(created_at: from..to).size
        }
    else
      @reviews = Review.all.order(params[:sort])
    end
    @review = Review.new
  end

  def edit
  end

  def update
    @review = Review.find(params[:id])
    tag_list = params[:review][:tag_name].split(',')
    if @review.update(review_params)
      @review.save_tag(tag_list)
      redirect_to review_path(@review), notice: "投稿を編集しました。"
    else
      render "edit"
    end
  end

  def destroy
    @review.destroy
    redirect_to reviews_path
  end

  private

  def review_params
    params.require(:review).permit(:stage_prefecture, :stage_name, :group, :body, :rate)
  end
  def ensure_correct_user
    @review = Review.find(params[:id])
    unless @review.user == current_user
      redirect_to reviews_path
    end
  end
end
