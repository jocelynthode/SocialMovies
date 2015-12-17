module ListsHelper
  def current_user_lists
    if user_signed_in?
      return current_user.lists.order("name ASC")
    end
    []
  end
end
