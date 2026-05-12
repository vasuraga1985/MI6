from pyspark.sql import functions as F
 
# Table name

table_name = "orders"
 
# Step 1: Ensure required columns exist (run once if needed)

spark.sql(f"""

ALTER TABLE {table_name} ADD COLUMNS (

  percentage DOUBLE

)

""")
 
# Step 2: Update only today's records in-place

spark.sql(f"""

UPDATE {table_name}

SET 

  percentage = order_amount * 0.2

WHERE to_date(order_date) = current_date()

""")
 
