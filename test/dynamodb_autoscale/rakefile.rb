require 'aws-sdk'

namespace 'dynamodb_autoscale' do
  load '../../scripts/tasks.rake'

  module DynamoDbAutoscaleShould
    def self.have_autoscaling_target(client, service_namespace, resource_id, scalable_dimension, min_capacity, max_capacity)
      
      params = {
        service_namespace: service_namespace, 
        resource_ids: [resource_id],
        scalable_dimension: scalable_dimension,
      }

      targets = client.describe_scalable_targets(params).scalable_targets

      if targets.length < 1
        raise "Scalable target does not exist"
      end

      if targets.length > 1
        raise "Too many scalable targets"
      end
      
      unless targets[0].min_capacity == min_capacity && targets[0].max_capacity == max_capacity
        puts resp.to_h
        raise 'Incorrect target'
      end

    end

    def self.have_autoscaling_policy(client, service_namespace, resource_id, scalable_dimension, target_value)
      
      params = {
        service_namespace: service_namespace, 
        resource_id: resource_id,
        scalable_dimension: scalable_dimension,
      }

      policies = client.describe_scaling_policies(params).scaling_policies

      if policies.length < 1
        raise "Scalable target does not exist"
      end

      if policies.length > 1
        raise "Too many scalable targets"
      end
      
      unless policies[0].target_tracking_scaling_policy_configuration.target_value == target_value
        puts resp.to_h
        raise 'Incorrect policy'
      end

    end
  end

  task :validate, [:prefix] do |_, args|
    
    aws_config = TDK::AwsConfig.new(TDK::Configuration.get('aws'))
    
    client = Aws::ApplicationAutoScaling::Client.new({ 
      region: aws_config.region, 
      credentials: aws_config.credentials 
    })

    DynamoDbAutoscaleShould.have_autoscaling_target(
        client, 
        "dynamodb", 
        "table/#{args.prefix}Table2",
        "dynamodb:table:ReadCapacityUnits",
        2,
        20)

    DynamoDbAutoscaleShould.have_autoscaling_policy(
        client, 
        "dynamodb", 
        "table/#{args.prefix}Table2",
        "dynamodb:table:ReadCapacityUnits",
        50)
  end
end
