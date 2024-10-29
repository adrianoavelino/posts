## ASDF: O Gerenciador de Versões que Você Precisa Conhecer!
Imagine que você está em um restaurante incrível, onde o menu oferece uma variedade de pratos principais. Cada prato pode ser personalizado com diferentes acompanhamentos, como arroz, salada ou batatas. Ao fazer seu pedido, você pode escolher a combinação exata que deseja, criando uma refeição perfeita para o seu paladar.

O asdf funciona de forma semelhante no mundo da programação. Ele é o seu restaurante de versões, permitindo que você escolha um "prato" (ou linguagem de programação) e adicione os "acompanhamentos" (as versões) que melhor atendem às suas necessidades. Assim como você pode ter diferentes combinações de pratos e acompanhamentos, com o asdf, você pode alternar entre várias versões de ferramentas e linguagens de forma rápida e fácil, garantindo que sua refeição esteja sempre do jeito que você gosta.

Neste post, vamos explorar como instalar e usar o **asdf** para gerenciar suas dependências de forma eficaz. Mas antes, vamos entender dois conceitos-chave: **plugins** e **versões**.

### **O que é o asdf?**
O **[asdf](https://asdf-vm.com/pt-br/)** é um gerenciador de versões universal que permite que você utilize múltiplas versões de linguagens de programação e ferramentas, tudo em um só lugar. Com ele, você pode alternar entre diferentes versões de uma mesma linguagem como se estivesse trocando de roupa, facilitando seu fluxo de trabalho e evitando conflitos.

Ao contrário de outros gerenciadores, como o **rbenv** para Ruby ou o **nvm** para Node.js, o **asdf** se destaca pela sua versatilidade. Ele suporta uma variedade de linguagens através de **plugins**. Você pode ter várias versões do Node.js, Python ou Java instaladas e alternar entre elas sem esforço. 

Ao contrário de outros gerenciadores, como o **[rbenv](https://github.com/rbenv/rbenv)** para Ruby ou o **[nvm](https://github.com/nvm-sh/nvm)** para Node.js, o **asdf** se destaca pela sua versatilidade. Ele suporta uma variedade de linguagens através de **plugins**. Você pode ter várias versões do Node.js, Python ou Java instaladas e alternar entre elas sem esforço.

Fábio Akita fala sobre o asdf no seu vídeo [The DEFINITIVE UBUNTU Guide for Beginning Devs](https://www.youtube.com/watch?v=epiyExCyb2s&t=2440s), no minuto **40:42**.

Neste post, vamos explorar como instalar e usar o **asdf** para gerenciar suas dependências de forma prática. Mas antes, vamos entender dois conceitos-chave: **plugins** e **versões**.

### Explicando os Conceitos
De acordo com a [documentação oficial](https://asdf-vm.com/pt-br/manage/plugins.html), **plugins** são as extensões que permitem ao **asdf** gerenciar diferentes ferramentas, como Node.js, Ruby e Elixir. Já as **versões** são as diferentes iterações das dependências que você pode utilizar. Por exemplo, você pode optar pela versão **v20.18.0** do Node.js para um projeto específico, enquanto usa uma versão diferente para outro.

Pronto para mergulhar no mundo do **asdf**? Então vamos à prática!

## Instalação do asdf
Clone o respositorio para a sua pasta home:
```bash
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.1
```

Execute os comandos abaixo para configurar o seu `~/.bashrc`:
```bash
echo '. "$HOME/.asdf/completions/asdf.bash"' >> ~/.bashrc
echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
```

Aplique as configurações no terminal ativo:
```bash
source ~/.bashrc
```

> Para outros tipos de shell como o zsh ou fish shell, [acesse a documentação oficial do asdf](https://asdf-vm.com/pt-br/guide/getting-started.html#_3-adicionando-ao-seu-shell).

## Principais Comandos do asdf
Esses são os comandos essenciais para instalar, listar e gerenciar versões no **asdf**.

- **`asdf list`**: Lista todos os plugins e as versões já instaladas no seu ambiente. Ideal para verificar rapidamente o que está disponível.

- **`asdf plugin add <NOME-DO-PLUGIN>`**: Adiciona um plugin ao **asdf** para que ele gerencie uma nova linguagem ou ferramenta. Por exemplo, para adicionar o plugin do Python, digite:
```bash
asdf plugin add python
```

- **`asdf list all <NOME-DO-PLUGIN>`**: Lista todas as versões disponíveis para um plugin específico, permitindo que você escolha a que deseja instalar. Exemplo para ver as versões do Python:
```bash
asdf list all python
```

- **`asdf install <NOME-DO-PLUGIN> <VERSAO>`**: Instala uma versão específica de uma linguagem ou ferramenta. Para instalar a versão 3.13.0 do Python, por exemplo, use:
```bash
asdf install python 3.13.0
```

- **`asdf global <NOME-DO-PLUGIN> <VERSAO>`**: Define uma versão específica de uma linguagem ou ferramenta como padrão para todo o sistema. Para definir a versão 3.13.0 do Python como global, digite:
```bash
asdf global python 3.13.0
```

- **`asdf local <NOME-DO-PLUGIN> <VERSAO>`**: Define uma versão específica de uma linguagem ou ferramenta apenas para o diretório atual do projeto. Navegue até a pasta do projeto e execute o comando. Por exemplo:
```bash
asdf local python 3.13.0
```
> Observação: esse comando gerar um arquivo chamado `.tool-versions` na pasta do projeto.


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
    git nano
```
