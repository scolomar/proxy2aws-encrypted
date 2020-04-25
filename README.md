This project consists of an NginX Reverse Proxy that will forward traffic from a cloud service to an internal service on premises and vice-versa.

The connection between the proxy and the services is done through HTTPS with Basic Authentication.

The proxy service is deployed in AWS on a production-grade highly available and secure infrastructure consisting of private and public subnets, NAT gateways, security groups and application load balancers in order to ensure the isolation and resilience of the different components.

Before creating the infrastructure you will need a Hosted Zone in AWS Route53:

```bash

# TO LIST THE EXISTING HOSTED ZONES
aws route53 list-hosted-zones --output text ;


```

In case you want to use HTTPS then you will also need a previously provisioned AWS Certificate:

```bash

# TO LIST THE EXISTING CERTIFICATES IN CASE YOU NEED HTTPS
aws acm list-certificates --output text ;


```

The template will create 6 EC2 machines spread on 3 different Availability Zones with Docker-CE installed, 3 Private and Public Subnets, 3 NAT Gateways, 2 Security Groups, 2 Application Load Balancers and the necessary Routes, Roles and attachments to ensure the isolation of the EC2 machines and the security and resilience of the whole infrastructure.

The EC2 machines do not have any open port accessible from outside.

We will use AWS Systems Manager to connect and maintain the EC2 machines without the need of any bastion or breaking the isolation.

You might need the following information if you want to connect to the machines via SSH:
* https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-getting-started-enable-ssh-connections.html
* https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html#install-plugin-linux

Here follow the links to the CloudFormation templates that define the infrastructure (you can choose to use HTTP, HTTPS or a mix of both):
* https://github.com/secobau/proxy2aws/tree/master/AWS/AMI

After you have successfully deployed the infrastructure in AWS you will create a Cloud9 instance to deploy a Highly Available Docker Swarm cluster consisting of three managers and three workers spread on three different Availability Zones. 

```BASH

# SET THE VARIABLE NAME OF THE STACK CREATED IN CLOUDFORMATION
stack=proxy2aws ;

# TO CREATE THE SWARM
rm -rf docker ;
export stack=$stack                                     \
  && git clone https://github.com/secobau/docker.git    \
  && chmod +x docker/AWS/install/Swarm/cluster.sh       \
  && ./docker/AWS/install/Swarm/cluster.sh              \
  && rm -rf docker ;


```

You will need a set of Docker Configs and Secrets to set up the configuration of the application. 

You can deploy the following samples instead of creating your own configuration:

```BASH

# IN CASE YOU NEED TO DEPLOY THE SAMPLE CONFIG FILES
rm -rf proxy2aws ;
export stack=$stack                                     \
  && git clone https://github.com/secobau/proxy2aws.git \
  && chmod +x proxy2aws/Shell/deploy-config.sh          \
  && ./proxy2aws/Shell/deploy-config.sh                 \
  && rm -rf proxy2aws ;


```

Now you will deploy the application. The Docker images are hosted in Docker Hub:
* https://hub.docker.com/r/secobau/proxy2aws

The deployment can use the latest image for Continous Integration or the specified release for Continuous Delivery. You will have to choose between the two. Depending on your choice the script will use the appropriate docker-compose file.

```BASH

# DEFINE THE TYPE OF DEPLOYMENT: LATEST OR RELEASE
deploy=release ;
deploy=latest ;

# TO DEPLOY THE APP
rm -rf proxy2aws ;
export stack=$stack                                     \
  && export deploy=$deploy                              \
  && git clone https://github.com/secobau/proxy2aws.git \
  && chmod +x proxy2aws/Shell/deploy.sh                 \
  && ./proxy2aws/Shell/deploy.sh                        \
  && rm -rf proxy2aws ;


```

The services will be available at the following URLs:
* https://aws2cloud.sebastian-colomar.com
* https://aws2prem.sebastian-colomar.com

After the deployment is finished it is a good idea to remove the Docker Configs and Secrets from the disk of the Manager:

```BASH

# TO REMOVE THE CONFIGS AND SECRETS FROM DISK
rm -rf proxy2aws ;
export stack=$stack                                     \
  && git clone https://github.com/secobau/proxy2aws.git \
  && chmod +x proxy2aws/Shell/remove-config.sh          \
  && ./proxy2aws/Shell/remove-config.sh                 \
  && rm -rf proxy2aws ;


```

Once you are finished you can remove the containers with the following script:

```BASH

# TO REMOVE THE APP
rm -rf proxy2aws ;
export stack=$stack                                     \
  && git clone https://github.com/secobau/proxy2aws.git \
  && chmod +x proxy2aws/Shell/remove.sh                 \
  && ./proxy2aws/Shell/remove.sh                        \
  && rm -rf proxy2aws ;


```

You can optionally remove the AWS infrastructure created in CloudFormation otherwise you might be charged for any created object:

```BASH

# TO REMOVE THE CLOUDFORMATION STACK
aws cloudformation delete-stack --stack-name $stack 


```


