FROM gitpod/workspace-full

# Install foundry forge
RUN sudo apt-get update \
 && sudo apt-get install -y \
 && curl -L https://foundry.paradigm.xyz | bash \
 && export PATH="$PATH:/home/gitpod/.foundry/bin" \
 && foundryup \
 && sudo rm -rf /var/lib/apt/lists/*
