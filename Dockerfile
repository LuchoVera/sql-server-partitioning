FROM mcr.microsoft.com/mssql/server:2019-latest

USER root

# Instalar herramientas necesarias
RUN apt-get update && apt-get install -y \
    curl \
    apt-transport-https \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Añadir repositorio de Microsoft y clave GPG
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list

# Instalar SQL Server tools
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y mssql-tools unixodbc-dev \
    && rm -rf /var/lib/apt/lists/*

# Añadir mssql-tools al PATH
ENV PATH "$PATH:/opt/mssql-tools/bin"

# Crear directorio para scripts
RUN mkdir -p /scripts

# Copiar scripts
COPY scripts/ /scripts/
COPY entrypoint.sh /

# Dar permisos de ejecución al script de entrada
RUN chmod +x /entrypoint.sh

USER mssql

# Establecer el script de entrada
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]

