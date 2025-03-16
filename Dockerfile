FROM mcr.microsoft.com/dotnet/sdk:8.0

ARG SERVER_VER="1449"
ARG TMODLOADER_VERSION="v2025.01.3.1"
ARG UID="999"

ENV INSTALL_LOC="/terraria"
ENV WORLDS_LOC="/worlds"
ENV MODS_LOC="/mods"
ENV LOGS_LOC="/logs"

ENV TERRARIA_DATA="/root/.local/share/Terraria/ModLoader"

RUN apt-get update && \
    apt-get install -y unzip curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -L \
        -o /tmp/terrariaServer.zip \
        https://terraria.org/api/download/pc-dedicated-server/terraria-server-${SERVER_VER}.zip && \
    curl -L \
        -o /tmp/tModLoader.zip \
        https://github.com/tModLoader/tModLoader/releases/download/${TMODLOADER_VERSION}/tModLoader.zip && \
    unzip -d /terraria /tmp/terrariaServer.zip && \
    unzip -d /terraria /tmp/tModLoader.zip

# TODO: fix; readd chowns to COPYs, adjust TERRARIA_DATA etc
# RUN useradd -m -u ${UID} -s /bin/false terraria

COPY ./default-config.txt /default-config.txt

RUN chmod +x ${INSTALL_LOC}/LaunchUtils/ScriptCaller.sh && \
    mkdir -p ${TERRARIA_DATA} ${LOGS_LOC} && \
    ln -s ${WORLDS_LOC} ${TERRARIA_DATA}/Worlds && \
    ln -s ${MODS_LOC} ${TERRARIA_DATA}/Mods && \
    ln -s ${LOGS_LOC} ${TERRARIA_DATA}/Logs
    # chown -R terraria:terraria ${TERRARIA_DATA}

VOLUME ${WORLDS_LOC} ${MODS_LOC}
WORKDIR ${INSTALL_LOC}
EXPOSE 7777
# USER terraria
ENTRYPOINT ["/terraria/LaunchUtils/ScriptCaller.sh"]
CMD ["-server", "-config", "/default-config.txt"]
