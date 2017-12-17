class ProfileController < ApplicationController
  before_action :set_user
  before_action :authenticate_user!

  def show
    if @user.present?
      render json: @user, serializer: PublicProfileSerializer, status: 200
    else
      render json: { errors: ["User not found"] }, status: 422
    end
  end

  def reviews
    if @user.present?
      render :json => @user.received_reviews.recent.to_json(:methods => [:from_avatar, :from_fullname, :from_id, :from_username, :to_avatar, :to_fullname, :to_id, :to_username]), status: 200
    else
      render json: { errors: ["User not found"] }, status: 422
    end
  end

  def events
    if @user.present?
      events = @user.events
      render :json => events.to_json(:methods => [:event_url, :user_avatar_url]), status: 200
    else
      render json: { errors: ["User not found"] }, status: 422
    end
  end

  def speak
    review = Review.create_review(@user, current_user, review_params)
    # redirect_to profile_reviews_path params[:username]
    if review.save
      render json: review, status: 201
    else
      render json: { errors: review.errors.full_messages }, status: 422
    end
  end

  def from_avatar
    current.avatar.url
  end

  def from_fullname
    current.fullname
  end

  def from_id
    current.id
  end

  def from_username
    current.username
  end
  
  def to_avatar
    @user.avatar.url
  end

  def to_fullname
    @user.fullname
  end

  def to_id
    @user.id
  end

  def to_username
    @user.username
  end

  private
    def review_params
      params.permit(:audio, :duration)
    end

    def set_user
      @user = User.find_by(fullname: params[:fullname])
    end
end