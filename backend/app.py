from flask import Flask, request, jsonify
from database import get_connection
import psycopg2

app = Flask(__name__)

@app.route("/")
def home():
    return jsonify({
        "message": "E-Commerce Inventory Management API",
        "status": "Running"
    })


# CREATE PRODUCT
@app.route("/products", methods=["POST"])
def add_product():
    data = request.get_json()

    try:
        conn = get_connection()
        cur = conn.cursor()

        cur.execute("""
            INSERT INTO products
            (product_name, category_id, supplier_id, price)
            VALUES (%s, %s, %s, %s)
            RETURNING product_id
        """, (
            data["product_name"],
            data["category_id"],
            data["supplier_id"],
            data["price"]
        ))

        product_id = cur.fetchone()[0]
        conn.commit()

        cur.close()
        conn.close()

        return jsonify({
            "message": "Product added successfully",
            "product_id": product_id
        }), 201

    except (KeyError, TypeError, ValueError):
        return jsonify({"error": "Invalid product data"}), 400
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# READ ALL PRODUCTS
@app.route("/products", methods=["GET"])
def get_products():
    conn = get_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT product_id, product_name, price
        FROM products
        ORDER BY product_id
    """)

    rows = cur.fetchall()

    cur.close()
    conn.close()

    return jsonify([
        {
            "product_id": r[0],
            "product_name": r[1],
            "price": float(r[2])
        } for r in rows
    ])


# UPDATE PRODUCT
@app.route("/products/<int:product_id>", methods=["PUT"])
def update_product(product_id):
    data = request.get_json()

    try:
        conn = get_connection()
        cur = conn.cursor()

        cur.execute("""
            UPDATE products
            SET product_name = %s,
                price = %s
            WHERE product_id = %s
            RETURNING product_id
        """, (
            data["product_name"],
            data["price"],
            product_id
        ))

        result = cur.fetchone()

        if not result:
            conn.rollback()
            return jsonify({"error": "Product not found"}), 404

        conn.commit()
        cur.close()
        conn.close()

        return jsonify({"message": "Product updated successfully"})

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# DELETE PRODUCT
@app.route("/products/<int:product_id>", methods=["DELETE"])
def delete_product(product_id):
    try:
        conn = get_connection()
        cur = conn.cursor()

        cur.execute("""
            DELETE FROM products
            WHERE product_id = %s
            RETURNING product_id
        """, (product_id,))

        result = cur.fetchone()

        if not result:
            conn.rollback()
            return jsonify({"error": "Product not found"}), 404

        conn.commit()
        cur.close()
        conn.close()

        return jsonify({"message": "Product deleted successfully"})

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# VIEW INVENTORY
@app.route("/inventory", methods=["GET"])
def get_inventory():
    conn = get_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT p.product_name, w.warehouse_name,
               i.quantity, i.reorder_level
        FROM inventory i
        JOIN products p ON p.product_id = i.product_id
        JOIN warehouses w ON w.warehouse_id = i.warehouse_id
        ORDER BY p.product_name
    """)

    rows = cur.fetchall()

    cur.close()
    conn.close()

    return jsonify([
        {
            "product": r[0],
            "warehouse": r[1],
            "quantity": r[2],
            "reorder_level": r[3],
            "low_stock": r[2] <= r[3]
        } for r in rows
    ])


# PROCESS ORDER
@app.route("/orders", methods=["POST"])
def create_order():
    data = request.get_json()

    try:
        conn = get_connection()
        cur = conn.cursor()

        cur.execute("""
            SELECT process_order(%s, %s, %s::jsonb)
        """, (
            data["customer_id"],
            data["warehouse_id"],
            __import__("json").dumps(data["items"])
        ))

        order_id = cur.fetchone()[0]

        conn.commit()
        cur.close()
        conn.close()

        return jsonify({
            "message": "Order processed successfully",
            "order_id": order_id
        }), 201

    except Exception as e:
        if 'conn' in locals():
            conn.rollback()
            conn.close()

        return jsonify({"error": str(e)}), 400


if __name__ == "__main__":
    app.run(debug=True, port=5000)