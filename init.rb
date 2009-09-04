require 'redmine'

Redmine::Plugin.register :redmine_issue_dashboard do
  name 'Redmine Dashboard plugin'
  author 'Oleg Vivtash'
  description 'Adds a dashboard with users and issues they\'re working on'
  version '0.2.1'

  #permission :issue_dashboard, {:dashboard => [:index]}, :require => :loggedin
  permission :view_dashboard, :dashboard => :index
  menu :top_menu, :issue_dashboard, { :controller => 'dashboard', :action => 'index' }, :caption => 'Dashboard'

end
