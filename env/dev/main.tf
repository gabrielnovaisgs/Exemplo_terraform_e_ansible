module "aws-dev" {
  source     = "../../infra"
  instancia  = "t2.micro"
  regiao_aws = "us-west-2"
  chave      = "dev-iac"
}

#por ser executado aqui, ele vai executar o que esta no main.tf da pasta infra
output "IP" {
  value = module.aws-dev.IP_publico
}
