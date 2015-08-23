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
      return redirect_to notifications_path, alert: "You aren't allowed to delete this notification."
    end

    @destroyed = @notification.destroy

    respond_to do |format|
      format.html do
        if @destroyed
          redirect_to notifications_path, notice: "Notification deleted successfully."
        else
          redirect_to notifications_path, alert: "Error: Notification could not be deleted."
        end
      end

      format.js
    end
  end

  def view_and_destroy
    @notification = Notification.find(params[:id])

    unless current_user == @notification.user
      return redirect_to notifications_path, alert: "You aren't allowed to view this notification."
    end

    if @notification.notable.present?
      view_path = polymorphic_path(@notification.notable)
    elsif @notification.link_controller.present?
      view_path = url_for(controller: @notification.link_controller,
        only_path: true)
    else
      view_path = notifications_path
    end

    if @notification.destroy
      redirect_to view_path
    else
      redirect_to view_path, alert: "Error: Notification could not be deleted."
    end
  end
end