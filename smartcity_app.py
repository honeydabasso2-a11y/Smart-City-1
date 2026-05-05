import mysql.connector
from datetime import datetime

# Connect to your database
db = mysql.connector.connect(
    host="localhost",
    port="3307",
    user="root",
    password="",
    database="smartcitydb"
)

cursor = db.cursor()

def show_menu():
    print("\n" + "="*40)
    print("    SMART CITY DB SYSTEM")
    print("="*40)
    print("1. View All City Zones")
    print("2. View All Traffic Sensors")
    print("3. View All Waste Bins")
    print("4. View Urgent Waste (Fill > 80%)")
    print("5. View Sensors with Zone Names (JOIN)")
    print("6. Average Fill Level Per Zone")
    print("7. Update Bin Fill Level (Test Trigger)")
    print("8. Call Stored Procedure (Zone Report)")
    print("9. Run Nested Query (Above Avg Fill)")
    print("10. Exit")
    print("="*40)

def view_zones():
    cursor.execute("SELECT * FROM CityZone")
    results = cursor.fetchall()
    print("\n--- CITY ZONES ---")
    for row in results:
        print(f"ID: {row[0]}, Name: {row[1]}, District: {row[2]}, Population: {row[3]}")

def view_sensors():
    cursor.execute("SELECT * FROM TrafficSensor")
    results = cursor.fetchall()
    print("\n--- TRAFFIC SENSORS ---")
    for row in results:
        print(f"ID: {row[0]}, Zone: {row[1]}, Location: {row[2]}, Status: {row[3]}")

def view_bins():
    cursor.execute("SELECT * FROM WasteBin")
    results = cursor.fetchall()
    print("\n--- WASTE BINS ---")
    for row in results:
        print(f"ID: {row[0]}, Zone: {row[1]}, Fill: {row[2]}%, Status: {row[4]}")

def view_urgent():
    try:
        cursor.execute("SELECT * FROM UrgentWaste")
        results = cursor.fetchall()
        print("\n--- URGENT WASTE (Fill > 80%) ---")
        for row in results:
            print(f"Bin ID: {row[0]}, Zone: {row[1]}, Fill: {row[2]}%")
    except:
        print("View 'UrgentWaste' not found. Please create it first.")

def view_join():
    cursor.execute("""
        SELECT ts.sensorID, ts.location, cz.zoneName, ts.status
        FROM TrafficSensor ts
        JOIN CityZone cz ON ts.zoneID = cz.zoneID
    """)
    results = cursor.fetchall()
    print("\n--- SENSORS WITH ZONE NAMES (JOIN) ---")
    for row in results:
        print(f"Sensor: {row[0]}, Location: {row[1]}, Zone: {row[2]}, Status: {row[3]}")

def view_avg_fill():
    cursor.execute("SELECT zoneID, AVG(fillLevel) FROM WasteBin GROUP BY zoneID")
    results = cursor.fetchall()
    print("\n--- AVERAGE FILL LEVEL PER ZONE ---")
    for row in results:
        print(f"Zone {row[0]}: Average Fill = {row[1]:.2f}%")

def update_bin():
    bin_id = int(input("Enter Bin ID to update: "))
    new_fill = int(input("Enter new fill level (0-100): "))
    
    cursor.execute("UPDATE WasteBin SET fillLevel = %s WHERE binID = %s", (new_fill, bin_id))
    db.commit()
    
    print(f"Bin {bin_id} updated to {new_fill}%")
    
    cursor.execute("SELECT * FROM AlertLog ORDER BY alertID DESC LIMIT 1")
    alert = cursor.fetchone()
    if alert:
        print(f"\n⚠️ ALERT TRIGGERED: {alert[3]} at {alert[4]}")

def call_procedure():
    zone_id = int(input("Enter Zone ID (1, 2, or 3): "))
    try:
        cursor.callproc("GetZoneReport", [zone_id])
        for result in cursor.stored_results():
            data = result.fetchall()
            print(data)
    except:
        print("Procedure 'GetZoneReport' not found. Please create it first.")

def nested_query():
    cursor.execute("""
        SELECT * FROM WasteBin
        WHERE fillLevel > (SELECT AVG(fillLevel) FROM WasteBin)
    """)
    results = cursor.fetchall()
    print("\n--- BINS ABOVE AVERAGE FILL LEVEL ---")
    for row in results:
        print(f"Bin ID: {row[0]}, Fill: {row[2]}%")

while True:
    show_menu()
    choice = input("Enter your choice: ")
    
    if choice == "1":
        view_zones()
    elif choice == "2":
        view_sensors()
    elif choice == "3":
        view_bins()
    elif choice == "4":
        view_urgent()
    elif choice == "5":
        view_join()
    elif choice == "6":
        view_avg_fill()
    elif choice == "7":
        update_bin()
    elif choice == "8":
        call_procedure()
    elif choice == "9":
        nested_query()
    elif choice == "10":
        print("Exiting... Goodbye!")
        break
    else:
        print("Invalid choice. Try again.")

cursor.close()
db.close()