# Introduction

This repository contains code for an IaC / Compliance-as-Code POC using Terraform, AWS, the OPA engine and possibly some custom scripts where needed.
As part of this demo we deploy a limited stack with selected security misconfigurations, with the inention to demonstrate detective and/or preventive control capabilities using open-source tools and built-in AWS services.


# Pre-requisites

- A sandbox AWS account and privileges to deploy resources to it
- The AWS CLI and the boto3 library for Python scripts
- Terraform
- Conftest - Used to run unit tests against structured configuration data such as Terraform code. Conftest uses the Rego language from [Open Policy Agent](https://www.openpolicyagent.org/) for writing the assertions. See [Conftest](https://www.conftest.dev/) 

# Scenario

- Deploy TF stack (main.tf and configrules.tf)
- Identify public SSH service:

```
nmap -sT -Pn -p 22 TARGET-IP
```

```
aws ec2 describe-security-groups --query 'SecurityGroups[?IpPermissions[?ToPort==`22` && contains(IpRanges[].CidrIp, `0.0.0.0/0`)]].{GroupId: GroupId, GroupName: GroupName, VpcId: VpcId}'
```
- Verify that a (detective) AWS Config rule was deployed as part of the TF stack using the AWS Console, or the CLI:
```
aws configservice describe-config-rules
```
- Access AWS Config in the Console to make sure the rule has fired - If you need to apply it again:
```
aws configservice put-config-rule --config-rule file://RestrictSSH.json
aws configservice start-config-rules-evaluation --config-rule-names restrict-ssh
```
- Todo: Programmatic/automated remediation of the issues

# Preventive controls
- After a 'terraform init', convert the plan to JSON so that OPA can process it:
```
terraform plan --out main.binary
terraform show -json main.binary > main.json
```
- Run the Rego rules in the (default) 'policy' directory using Conftest:
```
conftest test main.json
```


# Todo
- Automate remediation of unrestricted SSH rules using a serverless function, or write a custom script that will describe Security Groups, apply a filter, then call the ec2 'revoke-security-group-ingress' function - This may have broader consequences and we may want to make sure we can see what else is using that Security Group.
- Introduce more IAM PrivEsc vulns into stack and demonstrate enumeration using Checkov/pmapper

# Pain points
- To my knowledge there is no way to prevent the creation of such a rule via SCP - this emphasises the benefit of doing checks on IaC code before deployment
- Should use a more advanced set of Terraform modules to streamline stack definitions