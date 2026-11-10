
USE Ventas_Tech_DB;

-- Consulta 1: Resumen ejecutivo mensual
-- Muestra el total facturado, cantidad de pedidos y ticket promedio por mes.

SELECT 
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta);


-- Consulta 2: Ranking de productos (Top 5)
-- Top 5 de productos según su total facturado y unidades vendidas (Sintaxis SQL Server).

SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;

-- Consulta 3: Clientes recurrentes
-- Identifica clientes con más de un pedido, mostrando su total de compras y gasto acumulado.

SELECT 
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1;
-- Consulta 4: Productos por encima/por debajo del promedio
-- Clasifica cada producto según si su facturación supera o no el promedio general por producto.
WITH FacturacionPorProducto AS (
    SELECT 
        id_producto,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY id_producto
),
PromedioGeneral AS (
    SELECT 
        AVG(total_facturado) AS promedio_facturacion
    FROM FacturacionPorProducto
)
SELECT 
    f.id_producto,
    f.total_facturado,
    CASE 
        WHEN f.total_facturado >= p.promedio_facturacion THEN 'Por encima'
        ELSE 'Por debajo'
    END AS rendimiento_promedio
FROM FacturacionPorProducto f
CROSS JOIN PromedioGeneral p;

-- BLOQUE DE CIERRE: Hallazgos de Negocio
/*
HALLAZGOS CLAVE DEL ANÁLISIS DE VENTAS:

1. Concentración de Facturación en Top Productos:
   Un número reducido de productos dentro del Top 5 (Consulta 2) representa el mayor 
   volumen de los ingresos totales de marzo de 2024, evidenciando una alta dependencia 
   comercial en ítems específicos del catálogo Tech.

2. Comportamiento de Clientes Recurrentes:
   Los clientes identificados con más de un pedido (Consulta 3) generan un ticket 
   promedio superior al promedio general de la plataforma, lo que sugiere que las estrategias 
   de fidelización impactan directamente en el aumento del valor de vida del cliente (LTV).

3. Distribución del Rendimiento por Producto:
   La comparativa contra el promedio general (Consulta 4) permite detectar rápidamente 
   los productos catalogados 'Por debajo' que requieren revisión de precio, stock o 
   estrategias de promoción para optimizar su rotación en el inventario.
*/