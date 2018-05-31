alpine-rabbitmq-autocluster
===========================
Small RabbitMQ image (~42MB) with the autocluster plugin

RabbitMQ Version: 3.6.15
Autocluster Version: 0.10.0

|Stars| |Pulls|

Enabled plugins
---------------

- Autocluster 
- AWS
- Consistent Hash Exchange
- Delayed Message Exchange
- Federation
- Federation Management
- Management
- Management Visualiser
- Message Timestamp
- Recent History Exchange
- Sharding
- Top
- Web Dispatch

Configuration
-------------
All configuration of the auto-cluster plugin should be done via environment variables.

See the `RabbitMQ AutoCluster <https://github.com/aweber/rabbitmq-autocluster/wiki>`_
plugin Wiki for configuration settings.

Example Usage
-------------
The following example configures the ``autocluster`` plugin for use in an
AWS EC2 Autoscaling group:

.. code-block:: bash

   docker run -d \
    --name rabbitmq \
    --net=host \
    --dns-search=eu-west-1.compute.internal \
    --ulimit nofile=65536:65536 \
    --restart='always' \
    -p 1883:1883 \
    -p 4369:4369 \
    -p 5671:5671 \
    -p 5672:5672 \
    -p 15672:15672 \
    -p 25672:25672 \
    -e AUTOCLUSTER_TYPE=aws \
    -e AWS_AUTOSCALING=true \
    -e AUTOCLUSTER_CLEANUP=true \
    -e CLEANUP_WARN_ONLY=false \
    -e AWS_DEFAULT_REGION=us-west-1 \
    sohonet/alpine-rabbitmq-autocluster:3.6.15

To use the AWS autocluster features, you will need an IAM policy that allows the
plugin to discover the node list. The following is an example of such a policy:

.. code-block:: json

  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": [
                  "autoscaling:DescribeAutoScalingInstances",
                  "ec2:DescribeInstances"
              ],
              "Resource": [
                  "*"
              ]
          }
      ]
  }

If you do not want to use the IAM role for the instances, you could create a role
and specify the ``AWS_ACCESS_KEY_ID`` and ``AWS_SECRET_ACCESS_KEY`` when starting
the container.

I've included a `CloudFormation template <https://github.com/gmr/alpine-rabbitmq-autocluster/blob/master/cloudformation.json>`_
that should let you test the plugin. The template creates an IAM Policy and Role,
Security Group, ELB, Launch Configuration, and Autoscaling group.

The following is the user data snippet that for the Ubuntu image that is used
in the Launch Configuration:

.. code:: yaml

    #cloud-config
    apt_update: true
    apt_upgrade: true
    apt_sources:
      - source: deb https://apt.dockerproject.org/repo ubuntu-trusty main
        keyid: 58118E89F3A912897C070ADBF76221572C52609D
        filename: docker.list
    packages:
      - docker-engine
    runcmd:
      - export AWS_DEFAULT_REGION=`ec2metadata --availability-zone | sed s'/.$//'`
      - docker run -d --name rabbitmq --net=host -p 4369:4369 -p 5672:5672 -p 15672:15672 -p 25672:25672 -e AUTOCLUSTER_TYPE=aws -e AWS_AUTOSCALING=true -e AUTOCLUSTER_CLEANUP=true -e CLEANUP_WARN_ONLY=false -e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION sohonet/alpine-rabbitmq-autocluster:3.6.2-0.6.0


.. |Stars| image:: https://img.shields.io/docker/stars/sohonet/alpine-rabbitmq-autocluster.svg?style=flat&1
   :target: https://hub.docker.com/r/sohonet/alpine-rabbitmq-autocluster/

.. |Pulls| image:: https://img.shields.io/docker/pulls/sohonet/alpine-rabbitmq-autocluster.svg?style=flat&1
   :target: https://hub.docker.com/r/sohonet/alpine-rabbitmq-autocluster/
 (~42MB)
