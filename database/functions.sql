CREATE OR REPLACE FUNCTION process_order(
    p_customer_id INT,
    p_warehouse_id INT,
    p_items JSONB
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_order_id INT;
    v_item JSONB;
    v_product_id INT;
    v_quantity INT;
    v_price NUMERIC(10,2);
    v_available INT;
    v_total NUMERIC(12,2) := 0;
BEGIN
    INSERT INTO orders(customer_id, warehouse_id)
    VALUES(p_customer_id, p_warehouse_id)
    RETURNING order_id INTO v_order_id;

    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        v_product_id := (v_item->>'product_id')::INT;
        v_quantity := (v_item->>'quantity')::INT;

        IF v_quantity <= 0 THEN
            RAISE EXCEPTION 'Quantity must be positive';
        END IF;

        SELECT price INTO v_price
        FROM products
        WHERE product_id = v_product_id;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Product % not found', v_product_id;
        END IF;

        SELECT quantity INTO v_available
        FROM inventory
        WHERE product_id = v_product_id
          AND warehouse_id = p_warehouse_id
        FOR UPDATE;

        IF NOT FOUND OR v_available < v_quantity THEN
            RAISE EXCEPTION 'Insufficient stock for product %',
                v_product_id;
        END IF;

        UPDATE inventory
        SET quantity = quantity - v_quantity
        WHERE product_id = v_product_id
          AND warehouse_id = p_warehouse_id;

        INSERT INTO order_items(
            order_id, product_id, quantity,
            unit_price, subtotal
        )
        VALUES(
            v_order_id, v_product_id, v_quantity,
            v_price, v_price * v_quantity
        );

        INSERT INTO stock_movements(
            product_id, warehouse_id,
            movement_type, quantity, reference_id
        )
        VALUES(
            v_product_id, p_warehouse_id,
            'OUT', v_quantity, v_order_id
        );

        v_total := v_total + (v_price * v_quantity);
    END LOOP;

    UPDATE orders
    SET total_amount = v_total,
        status = 'Confirmed'
    WHERE order_id = v_order_id;

    RETURN v_order_id;
END;
$$;