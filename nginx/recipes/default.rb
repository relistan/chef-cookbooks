#
# Cookbook Name:: nginx
# Recipe:: default
#
# Copyright 2010, Example Com
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

gem_package "passenger"

execute "install-nginx" do
  command "/var/lib/gems/1.8/bin/passenger-install-nginx-module --auto --auto-download --prefix=/opt/nginx && touch /opt/.nginx-installed"
  not_if { File.exist? "/opt/.nginx-installed" }
end

link "/etc/nginx" do
  to "/opt/nginx/conf"
end

link "/var/www" do
  to "/opt/nginx/html"
end

directory "/var/log/nginx" do
  owner "www-data"
  group "root"
  mode "0755"
end

template "/etc/init.d/nginx" do
  source "nginx-init.erb"
  owner "root"
  group "root"
  mode "0755"
  backup false
end

template "/etc/nginx/nginx.conf" do
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  backup false
end

service "nginx" do
  action [ :enable, :start ]
  subscribes :restart, resources(:template => '/etc/nginx/nginx.conf')
end
