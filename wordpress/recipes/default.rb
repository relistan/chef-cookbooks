#
# Cookbook Name:: wordpress
# Recipe:: default
#
# Copyright 2011, Karl Matthias
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

require_recipe "php_fcgi"

package "php5-sqlite"
package "php-db"

directory "/opt/wordpress"

remote_file "/opt/wordpress/wordpress-3.0.4.tar.gz" do
  source "http://wordpress.org/wordpress-3.0.4.tar.gz"
  not_if { File.exist? "/opt/wordpress-3.0.4.tar.gz" }
end

execute "extract-wordpress" do
  cwd "/var/www"
  command "tar xzf /opt/wordpress/wordpress-3.0.4.tar.gz"
  not_if { File.exist? "/var/www/wordpress/index.php" }
end

directory "/var/www/wordpress" do
  owner "www-data"
  group "www-data"
  recursive true
end

remote_file "/opt/wordpress/pdo-for-wordpress.2.7.0.zip" do
  source "http://downloads.wordpress.org/plugin/pdo-for-wordpress.2.7.0.zip"
  not_if { File.exist? "/opt/wordpress/pdo-for-wordpress.2.7.0.zip" }
end

execute "extract-pdo-for-wordpress" do
  cwd "/var/www/wordpress/wp-content"
  command "unzip /opt/wordpress/pdo-for-wordpress.2.7.0.zip && mv pdo-for-wordpress/* . && rmdir pdo-for-wordpress"
  not_if { File.exist? "/var/www/wordpress/wp-content/db.php" }
end

directory "/var/www/wordpress/wp-content/pdo-for-wordpress" do
  mode "0755"
end

directory "/var/www/wordpress/wp-content/database" do
  owner "www-data"
end

template "/var/www/wordpress/wp-content/wp-config.php" do
  source "wp-config.php.erb"
  notifies :restart, resources(:service => "spawn-fcgi")
end

template "/var/www/wordpress/wp-content/wp-settings.php" do
  source "wp-settings.php.erb"
  notifies :restart, resources(:service => "spawn-fcgi")
end

remote_file "/opt/wordpress/platform-theme.1.0.8.zip" do
  source "http://wordpress.org/extend/themes/download/platform.1.0.8.zip"
  not_if { File.exist? "/opt/wordpress/platform-theme.1.0.8.zip" }
end

execute "extract-platform-theme" do
  cwd "/var/www/wordpress/wp-content/themes"
  command "unzip /opt/wordpress/platform-theme.1.0.8.zip"
  not_if { File.exist? "/var/www/wordpress/wp-content/themes/platform" }
end

file "/opt/nginx/html/wordpress/wp-content/themes/platform/core/css/dynamic.css" do
  owner "www-data"
  group "www-data"
end

directory "/opt/nginx/html/wordpress/wp-content/uploads/" do
  owner "www-data"
  group "www-data"
end

remote_file "/opt/wordpress/wp-syntax.0.9.9.zip" do
  source "http://downloads.wordpress.org/plugin/wp-syntax.0.9.9.zip"
  not_if { File.exist?  "/opt/wordpress/wp-syntax.0.9.9.zip" }
end

execute "extract-syntax-plugin" do
  cwd "/var/www/wordpress/wp-content/plugins/"
  command "unzip /opt/wordpress/wp-syntax.0.9.9.zip"
  not_if { File.exist? "/var/www/wordpress/wp-content/plugins/wp-syntax" }
end

directory "/var/www/wordpress/wp-content/plugins/wp-syntax" do
  mode 0755
end
