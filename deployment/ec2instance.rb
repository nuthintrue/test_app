require 'aws-sdk'

module Deployment
  class EC2Instance
    def initialize(cluster_name = 'default', desired_instance_count = 1, region = 'us-west-2')
      @cluster_name = cluster_name
      @ssh_key_name = "#{@cluster_name}_key"
      @region = region
      @client = Aws::EC2::Resource.new(region: @region)
      @vpc = virtual_private_cloud
      @ig = internet_gateway
      @sn = subnet
      @sg = security_group
      create_table_with_subnet
      create_key_pair
      create_ec2_instances(desired_instance_count)
      @client.instances
    end

    def virtual_private_cloud
      vpc = @client.create_vpc({ cidr_block: '10.200.0.0/16' })
      vpc.modify_attribute({ enable_dns_support: { value: true } })
      vpc.modify_attribute({ enable_dns_hostnames: { value: true } })
      vpc.create_tags({ tags: [{ key: 'Name', value: "#{@cluster_name}_vpc" }] })
      vpc
    end

    def internet_gateway
      igw = @client.create_internet_gateway
      igw.create_tags({ tags: [{ key: 'Name', value: "#{@cluster_name}_igw" }] })
      igw.attach_to_vpc(vpc_id: @vpc.vpc_id)
      igw
    end

    def subnet
      sn = @client.create_subnet({
        vpc_id: @vpc.vpc_id,
        cidr_block: '10.200.10.0/24',
        availability_zone: 'us-west-2a'
      })
      sn.create_tags({ tags: [{ key: 'Name', value: "#{@cluster_name}_subnet" }] })
      sn
    end

    def create_table_with_subnet
      table = @client.create_route_table({ vpc_id: @vpc.vpc_id })
      table.create_tags({ tags: [{ key: 'Name', value: "#{@cluster_name}_route_table" }] })
      table.create_route({ destination_cidr_block: '0.0.0.0/0', gateway_id: @ig.id })
      table.associate_with_subnet({ subnet_id: @sn.id })
    end

    def security_group
      sg = @client.create_security_group({
        group_name: 'test_app_security_group',
        description: 'test_app_security_group',
        vpc_id: @vpc.id
      })
      sg.authorize_ingress({
        ip_permissions: [
          {
            ip_protocol: 'tcp',
            from_port: 3000,
            to_port: 3000,
            ip_ranges: [{
              cidr_ip: '0.0.0.0/0'
            }]
          },
          {
            ip_protocol: 'tcp',
            from_port: 22,
            to_port: 22,
            ip_ranges: [{
              cidr_ip: '0.0.0.0/0'
            }]
          }]
      })
      sg
    end

    def create_key_pair
      client = Aws::EC2::Client.new(region: 'us-west-2')
      client.create_key_pair({ key_name: @ssh_key_name })
    end

    def create_ec2_instances(desired_instance_count = 1)
      script = "#!/bin/bash" + "\n" + "echo ECS_CLUSTER=#{@cluster_name} >> /etc/ecs/ecs.config"
      encoded_script = Base64.encode64(script)
      instance = @client.create_instances({
        image_id: 'ami-562cf236',
        min_count: desired_instance_count,
        max_count: desired_instance_count,
        key_name: @ssh_key_name,
        user_data: encoded_script,
        instance_type: 't2.micro',
        placement: {
          availability_zone: @region+'a'
        },
        network_interfaces: [
          {
            device_index: 0,
            subnet_id: @sn.id,
            groups: [@sg.id],
            delete_on_termination: true,
            associate_public_ip_address: true
          }
        ],
        iam_instance_profile: {
          arn: 'arn:aws:iam::' + '405986812585' + ':instance-profile/ecsInstanceRole'
        }
      })
      @client.client.wait_until(:instance_status_ok, { instance_ids: [instance[0].id] })
    end
  end
end
