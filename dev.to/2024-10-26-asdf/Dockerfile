FROM ubuntu:24.04

# Atualiza o sistema e instala as dependências
RUN apt-get update && apt-get install -y \
    make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev wget curl \
    llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev \
    git nano

# Instala e configura o asdf
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.1
RUN echo '. "$HOME/.asdf/completions/asdf.bash"' >> ~/.bashrc && \
    echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
