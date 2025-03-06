# Demo de SQL Server Partitioning

Esta demostración muestra cómo implementar y probar el particionamiento de tablas en SQL Server utilizando Docker.

## Descripción

El particionamiento de tablas es una técnica que divide una tabla grande en múltiples partes más pequeñas (particiones) basadas en un criterio específico, como fechas. Esto puede mejorar significativamente el rendimiento de las consultas al permitir que SQL Server solo acceda a las particiones relevantes.

En esta demo, crearemos:
- Una tabla normal con datos distribuidos entre diferentes años
- Una versión particionada de la misma tabla
- Compararemos el rendimiento entre ambas

## Requisitos previos

- [Docker](https://www.docker.com/products/docker-desktop)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Estructura del proyecto

```
.
├── Dockerfile                
├── docker-compose.yml        
├── entrypoint.sh             
├── scripts/
│   ├── init.sql             
│   ├── create_data.sql      
│   └── partitioning.sql     
└── README.md                
```

## Instalación y ejecución

1. Clone este repositorio:
   ```bash
   git clone <url-del-repositorio>
   cd <directorio-del-repositorio>
   ```

2. Inicie el contenedor:
   ```bash
   docker compose up -d
   ```

3. Espere a que el contenedor esté completamente inicializado (puede tomar unos minutos). Compruebe los logs:
   ```bash
   docker logs sqlserver
   ```

4. Conéctese a SQL Server:

    Windows
   ```bash
   winpty docker exec -it sqlserver //opt//mssql-tools//bin//sqlcmd -S localhost -U sa -P 'YourStrong!Passw0rd'
   ```
   Linux
   ```bash
   docker exec -it sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'YourStrong!Passw0rd'
   ```

## Comandos para la demostración

### 1. Verificar las Bases de Datos Existentes
```sql
SELECT name FROM sys.databases;
GO
```
> Nota: Si no aparece la Base de Datos `PartitioningTest`, verifique los logs con `docker logs sqlserver` para asegurarse de que la inicialización ha finalizado.

### 2. Cambiar a la Base de Datos PartitioningTest
```sql
USE PartitioningTest;
GO
```

### 3. Verificar las Tablas Creadas
```sql
SELECT name FROM sys.tables;
GO
```

### 4. Verificar el Número de Registros en Cada Tabla
```sql
SELECT 'LargeData' AS Tabla, COUNT(*) AS NumRecords FROM LargeData
UNION ALL
SELECT 'LargeData_Partitioned' AS Tabla, COUNT(*) AS NumRecords FROM LargeData_Partitioned;
GO
```

### 5. Verificar la Información de Particionamiento
```sql
SELECT 
    partition_number,
    rows
FROM sys.partitions
WHERE object_id = OBJECT_ID('LargeData_Partitioned');
GO
```
Este comando mostrará cómo se distribuyen los registros entre las diferentes particiones.

### 6. Comparar el Rendimiento entre Tablas
```sql
SET STATISTICS TIME ON;
GO
SELECT COUNT(*) 
FROM LargeData 
WHERE Date BETWEEN '2019-01-01' AND '2019-12-31';
GO
SELECT COUNT(*) 
FROM LargeData_Partitioned 
WHERE Date BETWEEN '2019-01-01' AND '2019-12-31';
GO
SET STATISTICS TIME OFF;
GO
```
Debería observar que la consulta en la tabla particionada es más rápida, especialmente porque solo necesita acceder a una partición específica en lugar de escanear toda la tabla.

## Explicación del particionamiento

En esta demo, el particionamiento se implementa de la siguiente manera:

1. **Función de partición**: `AnnualPartitionFunction` divide los datos por año, utilizando las fechas '2019-01-01', '2020-01-01' y '2021-01-01' como límites.

2. **Esquema de partición**: `AnnualPartitionScheme` asigna las particiones al filegroup PRIMARY.

3. **Tabla particionada**: `LargeData_Partitioned` se crea utilizando el esquema de partición, lo que significa que los datos se almacenan físicamente en particiones separadas según la fecha.

4. El tipo de particionamiento utilizado es `RANGE RIGHT`, lo que significa:
   - Datos < '2019-01-01' van a la partición 1
   - Datos >= '2019-01-01' y < '2020-01-01' van a la partición 2
   - Datos >= '2020-01-01' y < '2021-01-01' van a la partición 3
   - Datos >= '2021-01-01' van a la partición 4

## Limpieza

Para detener y eliminar el contenedor:

```bash
docker compose down
```

Para eliminar también los volúmenes persistentes:

```bash
docker compose down -v
```

## Datos a tomar en cuenta

- El script de inicialización puede tardar varios minutos debido a la inserción de datos de prueba.
- Asegúrese de asignar suficiente memoria al contenedor Docker (al menos 4GB recomendado).
- Al conectarse con SQL Server se debe escribir linea a linea