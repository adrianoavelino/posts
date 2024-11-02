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

Agora que já conhecemos os comandos básicos, vamos turbinar o nosso ambiente com alguns plugins e versões. Vêm comigo!


## Guia Prático para Instalação de Plugins e Versões com o asdf
Vamos instalar plugins e definir versões de linguagens e ferramentas populares com o **asdf**! A cada passo, você verá como configurar o ambiente para **Node.js**, **Java**, **Maven** e **Python** com comandos claros e diretos. 

### 🚀 Começando com Node.js
Para configurar o **Node.js** no seu ambiente, siga estes passos:

1. **Instalar dependências**: Vamos garantir que o sistema tenha tudo o que precisa.
```bash
sudo apt-get install dirmngr gpg curl gawk
```

2. **Adicionar o plugin do Node.js**: Com o plugin, o asdf será capaz de gerenciar versões do Node.
```bash
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
```

3. **Verificar o plugin instalado**:
```bash
asdf list
```
Você deve algo assim:
```
nodejs
  No versions installed
```
4. **Instalar uma versão do Node.js**: Liste as versões disponíveis ou instale diretamente a mais recente:
```bash
asdf list-all nodejs
   asdf install nodejs latest
```

5. **Definir a versão do Node.js**:
   - **Globalmente** (para todo o sistema):
```bash
asdf global nodejs latest
```

> Não se esqueça, o próximo passo é opcional!
   - **Localmente** (apenas no diretório atual):
```bash
asdf local nodejs v20.18.0 # ou qualquer outra versão disponível
```

### ☕ Configurando o Java
1. **Adicionar o plugin do Java**: Isso permite instalar e gerenciar versões do Java no **asdf**.
```bash
asdf plugin add java https://github.com/halcyon/asdf-java.git
```

2. **Verificar as versões disponíveis do Java**:
```bash
asdf list all java
```

3. **Configurar a variável JAVA_HOME**: Para garantir que o sistema identifique o Java.
```bash
echo . ~/.asdf/plugins/java/set-java-home.bash >> ~/.bashrc
```

4. **Instalar uma versão específica do Java**:
```bash
asdf install java adoptopenjdk-8.0.432+6
```

5. **Verificar a versão do Java instalada**:
```bash
java -version
```

6. **Definir a versão do Java globalmente**:
```bash
asdf global java adoptopenjdk-8.0.432+6
```

### 🔧 Configurando o Maven
1. **Adicionar o plugin do Maven**:
```bash
asdf plugin add maven
```

2. **Instalar a versão mais recente do Maven**:
```bash
asdf install maven latest
```

3. **Definir a versão global do Maven**:
```bash
asdf global maven latest
```

### 🐍 Configurando o Python
1. **Instalar dependências para o Python**:
```bash
sudo apt-get update && sudo apt-get install -y \
       make build-essential libssl-dev zlib1g-dev \
       libbz2-dev libreadline-dev libsqlite3-dev wget curl \
       llvm libncurses5-dev libncursesw5-dev \
       xz-utils tk-dev libffi-dev liblzma-dev \
       git
```

2. **Adicionar o plugin do Python**:
```bash
asdf plugin add python
```

3. **Instalar a versão mais recente do Python**:
```bash
asdf install python latest
```

4. **Definir a versão global do Python**:
```bash
asdf global python latest
```

Esses passos são suficientes para instalar e configurar as linguagens e ferramentas essenciais no **asdf**. Com essas instruções, seu ambiente estará preparado para alternar entre versões específicas conforme necessário.

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
