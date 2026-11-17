USE Ventas_Tech_DB;
GO

-- ============================================================================
-- MÓDULO 5: CONSULTAS CON JOINS Y UNION ALL
-- Base de datos: Ventas_Tech_DB
-- ============================================================================

-- Consulta 1: Vista base del proyecto (INNER JOIN)
-- Propósito: consolidar en una única vista enriquecida las ventas junto con los datos
-- descriptivos de clientes (incluyendo ciudad), productos y categorías para Power BI.
SELECT 
    v.id_venta,
    v.fecha_venta,
    c.id_cliente,
    c.nombre AS cliente,
    c.email,
    c.ciudad,
    p.id_producto,
    p.nombre_producto AS producto,
    cat.nombre_categoria AS categoria,
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario) AS total_venta
FROM ventas v
INNER JOIN clientes c ON v.id_cliente = c.id_cliente
INNER JOIN productos p ON v.id_producto = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta DESC;
-- Hallazgo: La vista integra las 10 transacciones registradas ($6.444,00 en total) cruzadas con 5 ciudades y 4 categorías de producto, dejando lista la tabla de hechos enriquecida para segmentar facturación por geografía y línea comercial en Power BI.


-- Consulta 2: Clientes sin ventas (LEFT JOIN)
-- Propósito: detectar clientes registrados en la base que aún no realizaron ninguna compra,
-- para que el área de CRM ejecute campañas de activación o primer descuento.
SELECT 
    c.id_cliente,
    c.nombre,
    c.email,
    c.ciudad,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL
ORDER BY c.fecha_registro DESC;
-- Hallazgo: 0 de los 5 clientes registrados aparecen sin compras; esto indica que el 100% de la base activa ya convirtió, por lo que CRM debe enfocar sus acciones en fidelización y recompra en lugar de activación inicial.


-- Consulta 3: Productos sin ventas (LEFT JOIN)
-- Propósito: identificar artículos del catálogo sin rotación registrada, para que el área
-- de Producto evalúe promociones, revisión de precios o discontinuación de stock.
SELECT 
    p.id_producto,
    p.nombre_producto AS producto,
    cat.nombre_categoria AS categoria,
    p.precio,
    p.stock
FROM productos p
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL
ORDER BY cat.nombre_categoria, p.nombre_producto;
-- Hallazgo: 0 de los 6 artículos del catálogo carecen de movimiento; todos los productos activos registran rotación comercial, permitiendo al área de Producto concentrar el análisis en reposición de stock de los ítems de mayor salida.


-- Consulta 4: Consolidado por canal (UNION ALL)
-- Propósito: comparar la facturación total segmentando las ventas en dos orígenes operativos
-- ('Online' vs. 'Presencial') mediante etiquetas fijas sin eliminar filas repetidas.
SELECT 
    canal, 
    COUNT(*) AS cantidad_operaciones,
    SUM(total) AS total_canal
FROM (
    SELECT 
        fecha_venta, 
        cantidad * precio_unitario AS total, 
        'Online' AS canal
    FROM ventas 
    WHERE cantidad <= 2

    UNION ALL

    SELECT 
        fecha_venta, 
        cantidad * precio_unitario AS total, 
        'Presencial' AS canal
    FROM ventas 
    WHERE cantidad > 2
) AS consolidado
GROUP BY canal
ORDER BY total_canal DESC;
-- Hallazgo: El canal Online lidera ampliamente tanto en volumen de operaciones como en facturación con 6 ventas por $5.310,00 (82,4% del ingreso total), frente a las 4 ventas de Presencial que suman $1.134,00 (17,6%).