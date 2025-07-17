# agent-image-builder

This is a proof of concept which combines aws ec2 image builder, event bridge and the buildkite agent.

#  Image Builder images owned by Amazon

* "arn:${AWS::Partition}:imagebuilder:${AWS::Region}:aws:image/ubuntu-server-22-lts-arm64/2025.5.8"
* "arn:${AWS::Partition}:imagebuilder:${AWS::Region}:aws:image/ubuntu-server-22-lts-x86/2025.5.8"

# Links 

* https://github.com/aws-samples/ec2-auto-scaling-instance-refresh-sample

# License

This application is released under Apache 2.0 license and is copyright [Mark Wolfe](https://www.wolfe.id.au).
