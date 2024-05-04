# init

get msh project
```shell
git clone git@github.com:beecode-rs/msh.git && \
cd msh
```

run script from the root of the project msh folder

```shell
echo "# clone packages" && \
git clone git@github.com:beecode-rs/msh-config.git          config                   && \
git clone git@github.com:beecode-rs/msh-base-temp.git       base-temp                && \
git clone git@github.com:beecode-rs/msh-app-boot.git        packages/app-boot        && \
git clone git@github.com:beecode-rs/msh-base-frame.git      packages/base-frame      && \
git clone git@github.com:beecode-rs/msh-cli.git             packages/cli             && \
git clone git@github.com:beecode-rs/msh-entity.git          packages/entity          && \
git clone git@github.com:beecode-rs/msh-env.git             packages/env             && \
git clone git@github.com:beecode-rs/msh-error.git           packages/error           && \
git clone git@github.com:beecode-rs/msh-logger.git          packages/logger          && \
git clone git@github.com:beecode-rs/msh-node-session.git    packages/node-session    && \
git clone git@github.com:beecode-rs/msh-orm.git             packages/orm             && \
git clone git@github.com:beecode-rs/msh-test-contractor.git packages/test-contractor && \
git clone git@github.com:beecode-rs/msh-util.git            packages/util            && \
echo "########" && \
echo "# done #" && \
echo "########"
```
