require_relative 'ec2instance'
require_relative 'ecscluster'

Deployment::ECSCluster.new(cluster_name = 'test_app', service_name = 'test_app')
instances = Deployment::EC2Instance.new(cluster_name='test_app', desired_instance_count = 2)
instances.each do |instance|
  puts instance.public_ip_address
end
