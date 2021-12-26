
## Login To AWS

```bash
$ aws configure
AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]: us-west-2
Default output format [None]: json
```

## Installation On AWS
```bash
terraform init
terraform plan
terraform apply
```


Define region
```bash
provider "aws" {
  region = var.AWS_REGION
}
```

Define variables
```bash
variable "AWS_REGION" {
  default = "eu-central-1"
}

variable "AMI" {
    default = "ami-0d527b8c289b4af7f"
}
```