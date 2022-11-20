class Public::ReviewsController < ApplicationController
  before_action :authenticate_user!

  def new
    @review = Review.new
  end

  def show
    @review = Review.find(params[:id])
    @review_comment = ReviewComment.new
    @review_tags = @review.tags
  end

  def create
    @review = Review.new(review_params)
    @review.user_id = current_user.id
    # 受け取った値を,で区切って配列にする
    tag_list = params[:review][:tag_name].split(',')
    if @review.save
      @review.save_tag(tag_list)
      redirect_to review_path(@review), notice: "投稿しました。"
    else
      render 'index'
    end
  end

  def index
    @reviews = Review.page(params[:page])
    @reviews = Review.all
    @user = current_user
    @review = Review.new
    @tag_list = Tag.all
  end

  def edit
    @review = Review.find(params[:id])
    @tag_list = @review.tags.pluck(:name).join(',')
  end

  def update
    @review = Review.find(params[:id])
    tag_list = params[:review][:name].split(',')
    if @review.update(review_params)
      @review.save_tag(tag_list)
      redirect_to review_path(@review.id), notice: "投稿を編集しました。"
    else
      render "edit"
    end
  end

  def destroy
    @review = Review.find(params[:id])
    @review.destroy
    redirect_to reviews_path
  end

  private

  def review_params
    params.require(:review).permit(:stage_prefecture, :stage_name, :group, :body, :rate, tag_ids:[])
  end

  def ensure_correct_user
    @review = Review.find(params[:id])
    unless @review.user == current_user
      redirect_to reviews_path
    end
  end
end
