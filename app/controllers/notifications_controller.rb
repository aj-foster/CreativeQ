class NotificationsController < ApplicationController

  before_filter :authenticate_user!

  def index
    @notifications = current_user.notifications
  end

  def read
    @notification = Notification.find(params[:id])

    unless current_user == @notification.user
      return redirect_to notifications_path, alert: "You aren't allowed to mark this notification as read."
    end

    @notification.mark_as_read
    redirect_to notifications_path
  end

  def destroy
    @notification = Notification.find(params[:id])

    unless current_user == @notification.user
      return redirect_to notifications_path, alert: "You aren't allowed destroy this notification."
    end

    if @notification.destroy
      redirect_to notifications_path, notice: "Notification deleted successfully."
    else
      redirect_to notifications_path, alert: "Error: Notification could not be deleted."
    end
  end

  def view_and_destroy
    @notification = Notification.find(params[:id])

    unless current_user == @notification.user
      return redirect_to notifications_path, alert: "You aren't allowed destroy this notification."
    end

    if @notification.destroy
      redirect_to order_path(@notification.order)
    else
      redirect_to order_path(@notification.order), alert: "Error: Notification could not be deleted."
    end
  end
end