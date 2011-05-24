node[:install_packages].each do |pkg|
  if pkg[:type] == 'package'
    package pkg[:name] do
      version pkg[:version] if pkg[:version]
    end
  elsif pkg[:type] == 'gem'
    gem_package pkg[:name] do
      version pkg[:version] if pkg[:version]
    end
  end
end
