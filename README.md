# Test App [![CircleCI](https://circleci.com/gh/nuthintrue/test_app/tree/master.svg?style=svg)](https://circleci.com/gh/nuthintrue/test_app/tree/master)

Note: This is an empty rails app with health check only. 

###To Spin Up Service:
1. install rmv with ruby 2.3.1
2. run 'gem install bundler'
3. run 'bundle install'
4. run 'rails server'

###Health Check:
localhost:3000/health_check

###Test:
coming soon

###ontinously Integration
circle.yml: contains CI pipeline without deployment (deployment coming soon)

###Docker Image Build:
Dockerfile: contains docker build of this test app
docker-compose.yml: contains the compose file of this app

###Deployment:
./deployment/ecscluster.rb: spin up an ECS cluster

./deployment/ec2instance.rb: spin up ec2instances that is dedicated for a specific cluster

./deployment/run_deployment.rb: spin up an ECS cluster with required instances and deploy this test app as service. 
