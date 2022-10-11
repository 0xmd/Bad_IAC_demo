# Introduction

This repository contains code for an IaC / Compliance-as-Code POC using Terraform, AWS, the OPA engine and possibly some custom scripts where needed.
As part of this demo we deploy a limited stack with selected security misconfigurations, with the inention to demonstrate detective and/or preventive control capabilities using open-source tools and built-in AWS services.

# Pre-requisites

- A sandbox AWS account and privileges to deploy resources to it
- The AWS CLI and the boto3 library for Python scripts
- Terraform
- We use [Conftest](https://github.com/open-policy-agent/conftest) as our Open Policy Agent wrapper; Conftest allows to write tests/policies using Rego, and run them against structured configuration data such as Terraform HCL code.

# Scenario

- Deploy TF stack (main.tf and configrules.tf)
- Identify public SSH service:

```
nmap -sT -Pn -p 22 TARGET-IP
```
- Identify offending Security Groups using the CLI:
```
aws ec2 describe-security-groups --query 'SecurityGroups[?IpPermissions[?ToPort==`22` && contains(IpRanges[].CidrIp, `0.0.0.0/0`)]].{GroupId: GroupId, GroupName: GroupName, VpcId: VpcId}'
```
- Verify that a AWS Config rule was deployed as part of the TF stack using the AWS Console, or the CLI:
```
aws configservice describe-config-rules
```
- Access AWS Config in the Console to make sure the rule has fired - If you need to apply it again:
```
aws configservice put-config-rule --config-rule file://RestrictSSH.json
aws configservice start-config-rules-evaluation --config-rule-names restrict-ssh
```
- Todo: Programmatic/automated remediation of the issues

# Could we have prevented this sooner?
- After a 'terraform init', convert the plan to JSON so that OPA can process it:
```
terraform plan --out main.binary
terraform show -json main.binary > main.json
```
- Run the Rego rules in the (default) 'policy' directory against the JSON plan using Conftest:
```
conftest test main.json
```

# Todo / Next steps

- Automate remediation of non-compliances found by AWS Config using SSM or a Lambda function - This may have broader consequences and we may want to make sure we can see what else is using that Security Group.
- Introduce more IAM PrivEsc vulns into stack and demonstrate enumeration using Checkov/pmapper + automate remediation

# Pain points

- To my knowledge there is no way to prevent the creation of such a rule via SCP - this emphasises the benefit of doing checks on IaC code before deployment
- Should use a more advanced set of Terraform modules to streamline stack definitions