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
> Observação: Este comando cria um arquivo chamado .tool-versions na pasta do projeto, permitindo configurar uma versão específica para cada repositório, independentemente da versão global.

Agora que já conhecemos os comandos básicos, vamos turbinar o nosso ambiente com alguns plugins e versões. Vêm comigo!


## Guia Prático para Instalação de Plugins e Versões com o asdf
Vamos instalar plugins e definir versões de linguagens e ferramentas populares com o **asdf**! A cada passo, você verá como configurar o ambiente para **Node.js**, **Java**, **Maven** e **Python**. 
> Observação: se você gostaria de sentir o sabor da ferramenta antes de configurar o ambiente localmente você pode ir para o item **(Opcional) Laboratório**

### 🚀 Começando com Node.js
Para configurar o **Node.js** no seu ambiente, siga estes passos:

1. **Instalar dependências**: Vamos garantir que o sistema tenha todas as dependências que você precisa.
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
Você deve ver algo assim:
```
nodejs
  No versions installed
```
4. **Instalar uma versão do Node.js**:

O primeiro passo antes de instalar uma versão, é escolher uma versão disponível e para isso liste as versões disponíveis:
```bash
asdf list all nodejs
```

Você deve ver uma lista semelhante ao exemplo abaixo:
```
...
22.11.0
23.0.0
23.1.0
```

Escolha uma das versões disponíveis e execute o comando abaixo para instalar, por exemplo, a versão **23.0.0**:
```bash
asdf install nodejs 23.0.0
```

5. **Definir a versão do Node.js**:
  - **Globalmente** (para todo o sistema):
```bash
asdf global nodejs 23.0.0
```

> Não se esqueça, o próximo passo é opcional, mas para executar, instale a versão **latest** com o comando `asdf install nodejs latest`.
   - **Localmente** (apenas no diretório atual):
```bash
asdf local nodejs latest # ou qualquer outra versão disponível
```

6. **Verifique a versão do nodejs**:
```bash
node --version
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
> Observação: você pode executar o comando `asdf list all java` para ver as versões disponíveis.

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

4. **Verifique a versão do maven instalada**:
```bash
mvn --version
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

5. **Verifique a versão do python**:
```bash
python --version
```

Esses passos são suficientes para instalar e configurar as linguagens e ferramentas essenciais no **asdf**. Com essas instruções, seu ambiente estará preparado para alternar entre versões específicas conforme necessário.

## (Opcional) Laboratório
Se você está aqui é porque você ficou interessado em testar o asdf antes de configurar em sua máquina. Sendo assim, vamos lá!

### Pré-requisitos:
- Docker
- Docker Compose

### Criando o ambiente
Para facilitar o laboratório com o asdf, preparamos um ambiente configurado e pronto para uso em um container Docker. Você só precisa criar os arquivos indicados abaixo:

Arquivo `Dockerfile`:
```bash
FROM ubuntu:24.04

# Atualiza o sistema e instala as dependências
RUN apt-get update && apt-get install -y \
    make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev wget curl \
    llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev \
    git nano sudo

# Adiciona um novo usuário
RUN useradd -m -s /bin/bash usuario && \
echo "usuario:123" | chpasswd && \
usermod -aG sudo usuario

# Da permissões sudo sem senha para o novo usuário
RUN echo "usuario ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Comando inicial para rodar o container no terminal do novo usuário
USER usuario

# Instala e configura o asdf
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.1
RUN echo '. "$HOME/.asdf/completions/asdf.bash"' >> ~/.bashrc && \
    echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc

CMD ["/bin/bash"]
```

Arquivo `docker-compose.yml`:
```bash
services:
  asdf:
    build:
      context: .  # Indica o diretório onde está o Dockerfile
      dockerfile: Dockerfile
    container_name: asdf
    tty: true  # Mantém o terminal aberto
```

### Construindo e executando o container
Com os arquivos prontos, execute o container com o comando abaixo:
```bash
docker compose up -d --build
```
Onde:
- `-d`: Executa o container em segundo plano
- `--build`: Recria o container se o Dockerfile mudar

> 💡 Isso deve demorar um tempinho para instalar todas as dependências... ⏳ Aproveite para esticar as canelas e tomar uma água 💧!

Após a instalação, acesse o container com o seguinte comando:
```bash
docker compose exec asdf bash
```

Agora você está pronto para seguir com o tutorial no tópico Guia Prático para Instalação de Plugins e Versões com o asdf e testar os comandos do asdf!

## Links
- [Documentação Oficial](https://asdf-vm.com/pt-br/)
- [Plugin asdf para NodeJS](https://github.com/asdf-vm/asdf-nodejs)
- [Plugin asdf para Java](https://github.com/halcyon/asdf-java)
- [Plugin asdf para Maven](https://github.com/halcyon/asdf-maven)
- [Plugin asdf para Python](https://github.com/asdf-community/asdf-python)
