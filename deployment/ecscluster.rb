require 'aws-sdk'
require_relative 'ec2instance'

module Deployment
  class ECSCluster
    def initialize(cluster_name = 'default', service_name = 'default', region = 'us-west-2')
      @region = region
      @client = Aws::ECS::Client.new(region: @region)
      @cluster_name = cluster_name
      @service_name = service_name
      create_cluster
      create_service
    end

    def create_cluster
      @client.create_cluster({ cluster_name: @cluster_name })
    end

    def create_service
      @client.create_service({
        cluster: "arn:aws:ecs:us-west-2:405986812585:cluster/#{@cluster_name}",
        desired_count: 3,
        service_name: @service_name,
        task_definition: "test-app",
      })
    end
  end
end
