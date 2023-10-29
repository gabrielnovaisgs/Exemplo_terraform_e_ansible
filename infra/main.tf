terraform {
  required_providers {

    aws = { #como eu estou me conectando 
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {          #dados daquele provedor especifico
  region = var.regiao_aws #region da aws
}

#Criando um lauch template: Template de maquina
resource "aws_launch_template" "maquina" { #
  image_id      = "ami-0efcece6bed30fd98"  #id da imagem que que quero para minha instancia (nesse caso ubuntu)
  instance_type = var.instancia            #qual instancia que eu quero subir
  key_name      = var.chave                #Adicionando uma chave ssh para acessar a instancia, criada como par de chaves na aws

  tags = {
    #nome que podemos colocar na instancia
    Name = "Instancia Terraform"
  }

  security_group_names = [var.grupoDeSeguranca]                       #nome do grupo de segurança que eu quero adicionar a minha instancia
  user_data            = var.producao ? filebase64("ansible.sh") : "" #arquivo que eu quero executar na minha instancia (nesse caso um script
}

#adicionando um par de chaves na aws
resource "aws_key_pair" "acessoSSH" {
  key_name   = var.chave
  public_key = file("${var.chave}.pub") #recuperando a chave do meu sistema
}

#Cria um grupo de auto scalling de acordo com a demanda
resource "aws_autoscaling_group" "grupo" {
  availability_zones = ["${var.regiao_aws}a", "${var.regiao_aws}b"] #zona de disponibilidade
  name               = var.nomeGrupo
  max_size           = var.maximo
  min_size           = var.minimo
  launch_template { #qual o modelo da maquina que eu quero subir
    id      = aws_launch_template.maquina.id
    version = "$Latest" #sempre ser a ultima versão
  }
  #arn = Amazon Resource Name
  target_group_arns = var.producao ? [aws_lb_target_group.alvoLoadbalancer[0].arn] : [] #para onde o loadBalancer mira as requisições
}

#Subnnet 1
resource "aws_default_subnet" "subnet_1" {
  availability_zone = "${var.regiao_aws}a"
}
#Subnnet 2
resource "aws_default_subnet" "subnet_2" {
  availability_zone = "${var.regiao_aws}b"
}

#Criando um load balancer
resource "aws_lb" "loadBalancer" {
  count    = var.producao ? 1 : 0                                             #se for produção ele cria um loadBalancer, se não ele não cria
  internal = false                                                            #se é interno ou externo
  subnets  = [aws_default_subnet.subnet_1.id, aws_default_subnet.subnet_2.id] #subnets que ele vai usar
}

#para onde o loadBalancer mira as requisições
resource "aws_lb_target_group" "alvoLoadbalancer" {
  count    = var.producao ? 1 : 0
  name     = "maquinasAlvo"
  port     = "8000"
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id
}

resource "aws_lb_listener" "entradaLoadBalancer" {
  count             = var.producao ? 1 : 0
  load_balancer_arn = aws_lb.loadBalancer[0].arn
  port              = "8000"
  protocol          = "HTTP"
  default_action {
    type             = "forward" # tipo de distribuidor de carga
    target_group_arn = aws_lb_target_group.alvoLoadbalancer[0].arn
  }
}


#Criando um virtual private cloud (VPC)
resource "aws_default_vpc" "default" { #default criado pela aws

}


#Criando a politica do autoscaling
resource "aws_autoscaling_policy" "escalaProducao" {
  count                  = var.producao ? 1 : 0
  name                   = "terraformEscala"
  autoscaling_group_name = var.nomeGrupo
  policy_type            = "TargetTrackingScaling" #Escala pelo consumo de CPU
  target_tracking_configuration {
    predefined_metric_specification {                     #Escala pelo consumo de CPU
      predefined_metric_type = "ASGAverageCPUUtilization" #Média da utilização de cpu
    }
    target_value = 50.0 #50% de utilização de cpu
    #acima disso ele cria novas maquinas e abaixo disso ele destroy as maquinas
  }
}
