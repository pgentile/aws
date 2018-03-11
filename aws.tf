provider "aws" {
  region = "${local.primary_region}"
}

provider "aws" {
  alias  = "secondary"
  region = "${local.secondary_region}"
}
