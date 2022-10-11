# Introduction

This repository contains code for an IaC / Compliance-as-Code POC using Terraform, AWS, the OPA engine and possibly some custom scripts where needed.
As part of this demo we deploy a limited stack with selected security misconfigurations, with the inention to demonstrate detective and/or preventive control capabilities using open-source tools and built-in AWS services.

# Pre-requisites

- A sandbox AWS account and privileges to deploy resources to it
- The AWS CLI and the boto3 library for Python scripts
- Terraform
- We use [Conftest](https://github.com/open-policy-agent/conftest) as our Open Policy Agent wrapper; Conftest allows to write tests/policies using Rego, and run them against structured configuration data such as Terraform HCL code

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
- Query AWS Config to see that the rule has fired:
```
aws configservice get-compliance-details-by-config-rule --config-rule-name restricted-ssh --compliance-types NON_COMPLIANT
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

- Automate remediation of non-compliances found by AWS Config using SSM or a Lambda function
- Make the scenario more elaborate by introducing several IAM PrivEsc vulns into stack, do enumeration using Checkov/pmapper + demonstrate that securing the environment will require several steps and control layers

# Pain points

- To my knowledge there is no way to prevent the creation of such a rule via SCP - this emphasises the benefit of doing checks on IaC code before deployment
- Should use a more advanced set of Terraform modules to streamline stack definitions