FROM ubuntu:20.04

WORKDIR /src

ENV TZ=America/Fortaleza
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update \
    && apt upgrade -y \
    && apt install -y curl tar xz-utils 

RUN useradd -ms /bin/bash vuejs
RUN mkdir /vuejs \
    && chown -R vuejs /vuejs \
    && chown -R vuejs /src
USER vuejs

RUN cd /tmp \
    && curl -C - -O https://nodejs.org/dist/v14.15.4/node-v14.15.4-linux-x64.tar.xz \
    && mkdir -p /vuejs/nodejs \
    && tar -xJvf /tmp/node-v14.15.4-linux-x64.tar.xz -C /vuejs/nodejs 

ENV PATH=/vuejs/nodejs/node-v14.15.4-linux-x64/bin:$PATH

RUN npm install -g yarn
RUN yarn global add @vue/cli @vue/cli-service-global
ENV PATH=/home/vuejs/.yarn/bin:$PATH

RUN mkdir /vuejs/src-default \
    && cd /vuejs/src-default \
    && vue create -n -d --merge . --skipGetStarted backend

# RUN echo 'test "$(ls -A /src)" || mv /vuejs/src-default/* /src/*' > /vuejs/start-project.sh \
#     && chmod +x /vuejs/start-project.sh
RUN echo -e '#!/bin/bash\nset -e\ntest "$(ls -A /src)" || mv /vuejs/src-default/* /src\nexec "$@"\n' >> /vuejs/docker-entrypoint.sh \
    && chmod +x /vuejs/docker-entrypoint.sh
    
EXPOSE 3000
EXPOSE 8080
EXPOSE 8000


ENTRYPOINT [ "/bin/bash", "/vuejs/docker-entrypoint.sh" ]
CMD ["vue", "ui", "--headless", "--port", "8000", "--host", "0.0.0.0" ]

