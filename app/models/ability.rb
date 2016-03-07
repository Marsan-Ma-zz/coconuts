class Ability
  include CanCan::Ability

  def initialize(user)

    if user.blank? # not logged in
      cannot :manage, :all
      basic_read_only
    elsif user.admin?  # login as admin
      can :manage, :all
    elsif user.editor? # login as editor
      can :create, Post
      basic_read_only
    else # login as common user
      cannot :manage, :all
      basic_read_only
    end

  end

  protected
    def basic_read_only
      can :read, Post 
      can :read, Category
      can :read, Tag
      can :read, User
      can :create, Feed
      can :update, Feed
    end
end
