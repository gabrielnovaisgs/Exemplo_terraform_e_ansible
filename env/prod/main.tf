module "aws-dev" {
  source           = "../../infra"
  instancia        = "t2.micro"
  regiao_aws       = "us-west-2"
  chave            = "prod-iac"
  grupoDeSeguranca = "Producao"
  minimo           = 1
  maximo           = 10
  nomeGrupo        = "PROD"
  producao         = true
}
