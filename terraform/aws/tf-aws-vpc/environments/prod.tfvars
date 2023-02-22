
// Set all NACLS open at the moment but will be locked down later
network_acls = {
    public_inbound = [
      {
        rule_number = 100
        rule_action = "allow"
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
     }
      ],
    public_outbound = [
      {
        rule_number = 110
        rule_action = "allow"
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      },
    ],
    private_inbound = [
      {
        rule_number = 120
        rule_action = "allow"
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
        }
    ],
    private_outbound = [
      {
        rule_number = 130
        rule_action = "allow"
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
        }
    ],
  }