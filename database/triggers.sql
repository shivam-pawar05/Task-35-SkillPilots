CREATE OR REPLACE FUNCTION log_inventory_changes()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO audit_log(
        table_name,
        operation,
        old_data,
        new_data
    )
    VALUES(
        TG_TABLE_NAME,
        TG_OP,
        CASE WHEN TG_OP = 'INSERT'
             THEN NULL ELSE to_jsonb(OLD) END,
        CASE WHEN TG_OP = 'DELETE'
             THEN NULL ELSE to_jsonb(NEW) END
    );

    RETURN CASE WHEN TG_OP = 'DELETE'
                THEN OLD ELSE NEW END;
END;
$$;

CREATE TRIGGER inventory_audit_trigger
AFTER INSERT OR UPDATE OR DELETE
ON inventory
FOR EACH ROW
EXECUTE FUNCTION log_inventory_changes();