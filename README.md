# Creating a lambda function

Using docker images from alertlogic I was not able to do a full end to end test using their examples.

Non up to date references:

* https://github.com/alertlogic/erllambda
* https://github.com/alertlogic/erllambda_elixir_example
* https://github.com/aws-samples/aws-lambda-elixir-runtime/tree/master/elixir_runtime

## Create the base app

```
mix new --app hello_world ./hello_world
cd hello_world
mix deps.get
```

### Add dependencies to your mix.exs

```
      {:erllambda, "~> 2.0"},
      {:mix_erllambda, "~> 1.1"},
      {:jiffy, "~> 0.15.2"}
```

### Tool versions (using asdf)

`.tool-versions`

```
elixir 1.9.2
```

### Create a dockerfile for the version you want

Because aws runs the bundled.zip file on a specific version of linux, we need to pull from it's base.

`dockerfile`
```
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
```

## Working with elixir code

### Getting the distillery release going

```
mkdir config
echo "use Mix.Config" > config/config.exs
mix distillery.init
rm -rf _build # cleaning it up since we will use docker to build the zip
```

### defining the handler

`hello_world.ex`

```
  def handle(event, context) do
    :erllambda.message("event: ~p", [event])
    :erllambda.message("context: ~p", [context])

    {:ok, response(%{ok: "yes"})}
  end

  defp to_json(to_convert) do
    to_convert |> :jiffy.encode
  end

  defp response(response) do
    %{
      statusCode: "200",
      body: to_json(response),
      headers: %{
        "Content-Type": "application/json"
      }
    }
  end
```

## Install and run

Example for getting a lambda function running:

```
docker build ./ -t local-aws-elixir-build
sudo rm -rf _build
mix deps.get
docker run -it --rm -v `pwd`:/buildroot -w /buildroot -e MIX_ENV=prod local-aws-elixir-build mix erllambda.release

```

Your zip bundle is now located here:
`./_build/prod/rel/hello_world/releases/0.1.0/hello_world.zip`

## AWS Functions

### Creation

```
aws lambda create-function --role $ROLE_ARN --function-name testHelloWorld --handler Elixir.HelloWorld --runtime provided --zip-file fileb://./_build/prod/rel/hello_world/releases/0.1.0/hello_world.zip

```

### Testing

```
aws lambda invoke --function-name testHelloWorld --log-type Tail --payload '{"msg": "a fake request"}'    outputfile.txt

```


### Code changes

To test new changes:

```
docker run -it --rm -v `pwd`:/buildroot -w /buildroot -e MIX_ENV=prod local-aws-elixir-build mix erllambda.release
aws lambda update-function-code --function-name testHelloWorld --zip-file fileb://./_build/prod/rel/hello_world/releases/0.1.0/hello_world.zip
```
