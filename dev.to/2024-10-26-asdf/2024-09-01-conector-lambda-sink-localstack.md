# ASDF
Quando falamos de gerenciador de versão de dependências no ambiente Ruby temos o [rbenv](https://github.com/rbenv/rbenv), no Javascript temos o [nvm](https://github.com/nvm-sh/nvm), no Java o [sdkman](https://sdkman.io/).

## Instalação do asdf
```bash
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.1
```

adicione no ~/.bashrc
echo '. "$HOME/.asdf/completions/asdf.bash"' >> ~/.bashrc
echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc

source ~/.bashrc

> Para outros tipos de shell como o zsh ou fish shell, [acesse a documentação oficial do asdf](https://asdf-vm.com/pt-br/guide/getting-started.html#_3-adicionando-ao-seu-shell).

## Node
https://github.com/asdf-vm/asdf-nodejs


Instalação de plugins
Exemplo com node

instala dependências
sudo apt-get install dirmngr gpg curl gawk

instala o pacote
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git

verifica o plugin instalado
asdf list: lista os plugins instalados

### instala uma versão especifica
asdf list-all nodejs: lista todas as versões do nodejs.

asdf install nodejs latest: instala a versão mais recente


### definindo uma versão
asdf global nodejs latest

asdf local nodejs v20.18.0


## Java
https://github.com/halcyon/asdf-java

instala plugin:
asdf plugin add java https://github.com/halcyon/asdf-java.git

Lista as versões disponíveis:
asdf list all java

configurar JAVA_HOME:
. ~/.asdf/plugins/java/set-java-home.bash

instala versão:
asdf install java adoptopenjdk-8.0.432+6

java -version

asdf global java adoptopenjdk-8.0.432+6


## mvn
https://github.com/halcyon/asdf-maven


Lista os plugins disponíveis:
asdf list

Instala o plugin:
asdf plugin add maven

instala versão:
asdf install maven latest

configura a versão com global:
asdf global maven latest


## Python
https://github.com/asdf-community/asdf-python

Lista os plugins disponíveis:
asdf list

instala dependecias para o plugin:
> apt-get update && apt-get install -y \
    make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev wget curl \
    llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev \
    git


asdf plugin add python


asdf install python latest


asdf global python latest

## Dicas


## Links

latest version docker image: Ubuntu 24.04.1 LTS


## Anotações
docker run -it ubuntu bash

```bash
apt update
apt install git
apt install nano
```

```bash
apt-get update && apt-get install -y \
    make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev wget curl \
    llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev \
    git
```