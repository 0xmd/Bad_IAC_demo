package main

deny_fully_open_ingress[msg] {
    resource := input.resource_changes[_]
    name := resource.name
    rule := resource.change.after.ingress[_]
    resource.type == "aws_security_group"
    contains(rule.cidr_blocks[_], "0.0.0.0/0") 
    msg = sprintf("ASG `%v` defines a fully open ingress", [name])
}