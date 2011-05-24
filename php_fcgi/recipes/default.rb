#
# Cookbook Name:: php_fcgi
# Recipe:: default
#
# Copyright 2010, Karl Matthias
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

%w{ php5-cli php5-cgi php5-xcache spawn-fcgi php5-mysql php-config php5-dev }.each do |pkg|
  package pkg do
    action :install
  end
end

template "/etc/php5/cgi/php.ini" do
  source "php.ini.erb"
  mode 0644
  owner "root"
  group "root"
end

template "/etc/php5/cgi/conf.d/xcache.ini" do
  source "xcache.ini.erb"
  mode 0644
  owner "root"
  group "root"
end

template "/etc/init.d/spawn-fcgi" do
  source "spawn-fcgi-init.erb"
  mode 0755
  owner "root"
  group "root"
end

service "spawn-fcgi" do
  supports :start => true, :stop => true, :restart => true
  action [:enable, :start]
  status_command "pgrep php-cgi"
  running
end

# Complex rule to make sure all the nginx config pieces are in place before restarting.
# Otherwise Nginx dies on startup.
execute "restart-spawn-fcgi" do
  command do
    subscribes :restart, resources(:template => "/etc/init.d/spawn-fcgi")
    subscribes :restart, resources(:template => "/etc/php5/cgi/php.ini")
    subscribes :restart, resources(:template => "/etc/php5/cgi/conf.d/xcache.ini")
    notifies :restart, resources(:service => "spawn-fcgi")
  end
  only_if do
    File.exist?("/etc/php5/cgi/php.ini") && 
    File.exist?("/etc/php5/cgi/conf.d/xcache.ini") && 
    File.exist?("/etc/init.d/spawn-fcgi") 
  end
  action :nothing
end

