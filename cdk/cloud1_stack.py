from aws_cdk import (
    Stack,
    aws_ec2 as ec2,
    CfnOutput
)
from constructs import Construct

class Cloud1Stack(Stack):
    def __init__(self, scope: Construct, id: str, config: dict, **kwargs):
        super().__init__(scope, id, **kwargs)

        vpc = ec2.Vpc.from_lookup(self, "DefaultVPC", is_default=True)

        sg = ec2.SecurityGroup(self, "SecurityGroup",
            vpc=vpc,
            description="Allow SSH, HTTP, HTTPS",
            allow_all_outbound=True
        )

        sg.add_ingress_rule(ec2.Peer.any_ipv4(), ec2.Port.tcp(22), "Allow SSH")
        sg.add_ingress_rule(ec2.Peer.any_ipv4(), ec2.Port.tcp(80), "Allow HTTP")
        sg.add_ingress_rule(ec2.Peer.any_ipv4(), ec2.Port.tcp(443), "Allow HTTPS")

        instance = ec2.Instance(self, "Cloud1Instance",
            instance_type=ec2.InstanceType(config["instance_type"]),
            machine_image=ec2.MachineImage.generic_linux({
                config["region"]: config["ami_id"]
            }),
            vpc=vpc,
            key_name=config["key_name"],
            security_group=sg
        )

        eip = ec2.CfnEIP(self, "ElasticIP")

        ec2.CfnEIPAssociation(self, "EIPAssociation",
            instance_id=instance.instance_id,
            eip=eip.ref
        )

        for key, value in config.get("tags", {}).items():
            instance.node.default_child.tags.set_tag(key, value)

        CfnOutput(self, "ElasticIPAllocationId", value=eip.ref)
        CfnOutput(self, "InstanceID", value=instance.instance_id)
