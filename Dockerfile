FROM lambci/lambda-base:build

RUN yum install -y make automake gcc gcc-c++ kernel-devel git wget openssl-devel ncurses-devel wxBase3 wxGTK3-devel m4 autoconf readline-devel libyaml-devel libxslt-devel libffi-devel libtool unixODBC-devel unzip curl && \
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.4 && \
    echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bashrc && \
    echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc && \
    source ~/.bashrc && \
    asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git && \
    asdf install elixir 1.9.2 && \
    asdf global elixir 1.9.2 && \
    asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git && \
    asdf install erlang 22.0.7 && \
    asdf global erlang 22.0.7
ENV PATH /root/.asdf/shims:/root/.asdf/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin