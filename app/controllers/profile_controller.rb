class ProfileController < ApplicationController
  before_action :set_user
  before_action :authenticate_user!

  def show
    user = User.find_by(username: params[:username])
    if user.present?
      render json: user, serializer: PublicProfileSerializer, status: 200
    else
      render json: { errors: ["User not found"] }, status: 422
    end
  end

  def events
    events = @user.events
    render json: events, status: 200
  end

  def write
    review = Review.create_review(@user, current_user, review_params)
    # redirect_to profile_reviews_path params[:username]
    if review.save
      render json: review, status: 201
    else
      render json: { errors: review.errors.full_messages }, status: 422
    end
  end

  def reviews
    @reviews = @user.received_reviews.recent
    render json: @reviews, status: 200
  end

  private
    def review_params
      params.permit(:content, :isPositive)
    end

    def set_user
      @user = User.find_by(fullname: params[:fullname])
    end
end