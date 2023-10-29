resource "aws_security_group" "acesso_web" {
  name = var.grupoDeSeguranca
  ingress {
    cidr_blocks      = ["0.0.0.0/0"] #todas entradas de IPv4
    ipv6_cidr_blocks = ["::/0"]      #todas entradas de IPv6
    #De 0 a 0 siginifica que qualquer porta pode ser acessada
    from_port = 0    #porta de entrada
    to_port   = 0    #porta de saida
    protocol  = "-1" #qualquer protocolo 
  }

  egress {
    cidr_blocks      = ["0.0.0.0/0"] #todas entradas de IPv4
    ipv6_cidr_blocks = ["::/0"]      #todas entradas de IPv6
    #De 0 a 0 siginifica que qualquer porta pode ser acessada
    from_port = 0    #porta de entrada
    to_port   = 0    #porta de saida
    protocol  = "-1" #qualquer protocolo 
  }
  tags = {
    "Name" = "Acesso web"
  }
}
