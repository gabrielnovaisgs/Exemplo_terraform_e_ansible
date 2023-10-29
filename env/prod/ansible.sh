#!/bin/bash
cd /home/ubuntu
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py #salva o arquivo get-pip.py
sudo python3 get-pip.py #instala o pip
sudo python3 -m pip install ansible #instala o ansible
tee -a playbook.yml > /dev/null <<EOT #cria o arquivo playbook.yml e insere o conteudo
- hosts: localhost
  tasks: 
    - name: Instalando python3, virtualenv
      apt: 
        pkg: 
          - python3
          - virtualenv
        update_cache: yes
      become: true 
    
    - name: Git Clone
      ansible.builtin.git:
        repo: https://github.com/alura-cursos/clientes-leo-api
        dest: /home/ubuntu/teste #destino do clone
        version: master 
        force: yes 

    - name: Instalando dependencias com pip (Django e Django Rest)
      pip:
        virtualenv: /home/ubuntu/teste/venv #caminho da virtualenv
        requirements: /home/ubuntu/teste/requirements.txt #caminho do arquivo de dependencias

    - name: Alterando o hosts do settings
      lineinfile: #altera uma linha do arquivo
        path: /home/ubuntu/teste/setup/settings.py #arquivo que será alterado
        regexp: '^ALLOWED_HOSTS' #expressão regular para encontrar a linha
        line: 'ALLOWED_HOSTS = ["*"]' # linha que será inserida
        backrefs: yes # para que o ansible caso não encontre a linha, não insira nada

    - name: Configurando o banco de dados
      shell: |
        source /home/ubuntu/teste/venv/bin/activate
        python /home/ubuntu/teste/manage.py migrate
      args: #Garantindo que o comando será executado no bash
       executable: /bin/bash
    - name: Carregando dados iniciais
      shell: |
        source /home/ubuntu/teste/venv/bin/activate
        python /home/ubuntu/teste/manage.py loaddata clientes.json
      args: #Garantindo que o comando será executado no bash
            executable: /bin/bash

    - name: iniciando o servidor
      shell: |
        source /home/ubuntu/teste/venv/bin/activate
        nohup python3 /home/ubuntu/teste/manage.py runserver 0.0.0.0:8000 &
EOT

sudo ansible-playbook playbook.yml #executa o playbook
