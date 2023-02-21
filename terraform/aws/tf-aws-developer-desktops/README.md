# tf-aws-developer-desktops

## Purpose

To create developer desktops for the dev team to use.

# tf-aws-developer-desktops

[![infracost](https://img.shields.io/endpoint?url=https://dashboard.api.infracost.io/shields/json/ade6445a-b1e2-44f5-b290-4d7bc092ff03/repos/0d29ad6b-4c8a-4d02-b466-e29c15b57e3b/branch/1d3b5b72-26fb-4ee9-a5b6-4c6f479e4e82)](https://dashboard.infracost.io/org/jamesirvine/repos/0d29ad6b-4c8a-4d02-b466-e29c15b57e3b)

## Purpose

## Usage

### AWS Workspaces

**Pre-reqs**

- Install AWS Workspaces (https://clients.amazonworkspaces.com/)

**Instructions**

- Load up AWS Workspaces application

- Enter `Registration Code` obtained from cloud admin or from the outputs of this Terraform project

- When prompted enter your Active Directory credentials

**Information**

- Users have local admin

- Software preinstalled is:

  - Visual Studio 2022 Professional
  - VS Code
  - Git for Windows
  - gpgWin
  - DotNet SDK 6
  - DotNet SDK 7
  - Putty
  - pgAdmin
  - mySQL Workbench
  - All Windows Updates (as of Mon 30th Jan 2023)


### ec2 instances

#### Method 1: SSM (recommended)

**Pre-reqs**

- AWS CLI installed - https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

- Session Manager Plugin installed - https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html

**Instructions**

Run the following command replacing <INSERT_YOUR_INSTANCE_ID_HERE> with the id of your ec2 instance.


`aws ssm start-session --target <INSERT_YOUR_INSTANCE_ID_HERE> --document-name AWS-StartPortForwardingSession --parameters "localPortNumber=55678,portNumber=3389"`

The above example will forward RDP to your localhost on port 55678. 

Once established you can fire up your RDP client and connect to `localhost:55678` through the secure tunnel.


### Contributors

- @ntt-james [james.irvine@nttdata.com]
- @amani78 [amar.mani@nttdata.com]