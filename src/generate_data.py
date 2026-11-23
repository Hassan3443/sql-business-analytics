"""Generate the source CSVs for the analytics database (synthetic, reproducible)."""
import random
import csv
from datetime import date, timedelta

random.seed(11)

CATEGORIES = {
    "Electronics": ["Wireless Mouse", "Bluetooth Speaker", "USB-C Hub", "Webcam HD", "Mechanical Keyboard"],
    "Clothing": ["T-Shirt", "Jeans", "Hoodie", "Sneakers", "Cap"],
    "Home & Kitchen": ["Coffee Maker", "Blender", "Cookware Set", "Desk Lamp", "Air Fryer"],
    "Books": ["Python Handbook", "Data Science 101", "Novel", "Cookbook", "Biography"],
    "Sports": ["Yoga Mat", "Dumbbells", "Football", "Jump Rope", "Water Bottle"],
}
PRICE_RANGE = {"Electronics": (500, 5000), "Clothing": (150, 1200),
               "Home & Kitchen": (200, 2500), "Books": (80, 400), "Sports": (100, 1500)}
REGIONS = ["Cairo", "Alexandria", "Giza", "Mansoura", "Aswan"]
FIRST = ["Ahmed", "Mohamed", "Sara", "Nour", "Omar", "Mariam", "Youssef", "Hana", "Khaled", "Salma"]
LAST = ["Hassan", "Ibrahim", "Ali", "Mahmoud", "Sayed", "Farouk", "Nasser", "Adel", "Fathy", "Kamel"]


def main():
    customers = []
    for i in range(1, 1201):
        customers.append({
            "customer_id": i,
            "name": f"{random.choice(FIRST)} {random.choice(LAST)}",
            "region": random.choices(REGIONS, weights=[38, 22, 18, 12, 10])[0],
            "signup_date": (date(2023, 1, 1) + timedelta(days=random.randint(0, 900))).isoformat(),
        })

    products = []
    pid = 1
    for cat, names in CATEGORIES.items():
        lo, hi = PRICE_RANGE[cat]
        for name in names:
            price = round(random.uniform(lo, hi), 2)
            products.append({"product_id": pid, "product_name": name,
                             "category": cat, "unit_price": price})
            pid += 1

    orders, items = [], []
    oid = 1
    for day_offset in range(730):
        day = date(2024, 1, 1) + timedelta(days=day_offset)
        for _ in range(random.randint(1, 5)):
            customer = random.choice(customers)
            orders.append({"order_id": oid, "customer_id": customer["customer_id"],
                           "order_date": day.isoformat(),
                           "status": random.choices(["delivered", "shipped", "cancelled", "returned"],
                                                    weights=[78, 12, 6, 4])[0]})
            for _ in range(random.choices([1, 2, 3], weights=[60, 30, 10])[0]):
                product = random.choice(products)
                items.append({"order_id": oid, "product_id": product["product_id"],
                              "quantity": random.choices([1, 2, 3], weights=[70, 20, 10])[0],
                              "unit_price": product["unit_price"]})
            oid += 1

    for name, rows in [("customers", customers), ("products", products),
                       ("orders", orders), ("order_items", items)]:
        with open(f"data/{name}.csv", "w", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
            writer.writeheader()
            writer.writerows(rows)
        print(f"{name}: {len(rows)} rows")


if __name__ == "__main__":
    main()
