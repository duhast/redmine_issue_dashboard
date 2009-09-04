class DashboardController < ApplicationController
unloadable

before_filter :require_admin

  def efforts_table
    get_users if request.xhr?

    #For MyEffort table
    @efforts_board_data = []
    @users.each do |user|
      his_effort = UserEffort.find_by_user_id(user.id)
      issue = 0
      project = 0
      estimate = 0
      unless his_effort.nil?
        issue = Issue.find_by_id(his_effort.issue_id)
        project = Project.find_by_id(issue.project_id)
        estimate = issue.estimated_hours || 0
      end
      @efforts_board_data << {:user => user, :issue => issue, :project => project, :estimated_time => estimate, :spent_time => (his_effort.nil? ? nil : his_effort.hours_spent)}
    end

    if request.xhr?
      @efforts_board_data = sort_table(@efforts_board_data)
      render :partial => 'table_working_on', :locals => {:table_data => @efforts_board_data}
    end
  end

  def issues_user_table
    get_users if request.xhr?

    #For issue per user table
    @issues_per_user = Array.new
    @users.each do |user|
      issues = Issue.find(:all, :conditions => {:assigned_to_id => user})
      issues.reject! { |j| j.status.is_closed? }
      all_count = issues.length
      new_count = issues.reject { |f| !@good_status_id.include?(f.status.id) }.length
      @issues_per_user << {:user => user, :new => new_count, :total => all_count}
    end

    if request.xhr?
      @issues_per_user = sort_table(@issues_per_user)
      render :partial => 'table_issues_user', :locals => {:table_data => @issues_per_user}
    end
  end

  def issues_project_table
    get_users if request.xhr?

    #Issues by project
    @projects = Project.find(:all, :conditions => {:status => Project::STATUS_ACTIVE })

    @issues_per_project = Array.new
    @projects.each do |proj|
      issues = proj.issues
      issues.reject! { |j| j.status.is_closed? }
      all_count = issues.length
      new_count = issues.reject { |f| !@good_status_id.include?(f.status.id) }.length
      @issues_per_project << {:project => proj, :new => new_count, :total => all_count}
    end

    if request.xhr?
      @issues_per_project = sort_table(@issues_per_project)
      render :partial => 'table_issues_project', :locals => {:table_data => @issues_per_project}
    end
  end

  def index
    get_users
    efforts_table
    issues_user_table
    issues_project_table
  end

protected
  def get_users
    @users = User.find(:all)
    @users.reject! { |usr| [User::STATUS_ANONYMOUS, User::STATUS_LOCKED].include?(usr.status) }

    @good_status_id = []
    @good_status_id << IssueStatus.find_by_name('New').id
    @good_status_id << IssueStatus.find_by_name('Review').id
  end

  def sort_table(tabledata)
    sort_key = params[:sort_key]
    unless sort_key.nil?
      if 'user'.eql?(sort_key) #by user
        sorted_data = tabledata.sort_by { |h| h[:user].name  }
      elsif 'issue_id'.eql?(sort_key) #by issue id
        sorted_data = tabledata.sort_by { |h| h[:issue].id  }
      elsif 'project_name'.eql?(sort_key) #by project_name
        sorted_data = tabledata.sort_by { |h| h[:project].name  }
      elsif ['new', 'total', 'estimated_time'].include?(sort_key) #by numbers
        sorted_data = tabledata.sort_by { |h| h[sort_key.to_sym]  }
      elsif 'spent_time'.eql?(sort_key) #by effort
        sorted_data = tabledata.sort_by { |h| h[:spent_time].nil? ? 0 : h[:spent_time] }
      else
        sorted_data = tabledata # unknown sort key
      end
      sorted_data.reverse! if params[:sort_asc].nil?
    end
    sorted_data
  end

end
