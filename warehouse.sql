SELECT
		 "Purchase Order Items"."Item ID" as "Item ID",
		 "Purchase Order Items"."Item Name" as "Item Name",
		 "Warehouses"."Warehouse Name" as "Warehouse",
		 "Purchase Order Items"."Created Time" as 'Date',
		 "Purchase Order Items"."Quantity" as "Quantity In",
		 0 as "Quantity Out",
		 0 as "Committed Stock",
		 'Purchase Received Item' as 'Type',
		 "Stock In Flow Table"."Stock In Hand" as "Stock In Hand"
FROM  "Purchase Order Items"
JOIN "Purchase Orders" ON "Purchase Orders"."Purchase Order ID"  = "Purchase Order Items"."Purchase Order ID" 
LEFT JOIN "Purchase Receive Items" ON "Purchase Receive Items"."Purchase Order Item ID"  = "Purchase Order Items"."Item ID" 
LEFT JOIN "Warehouses" ON "Warehouses"."Warehouse ID"  = "Purchase Order Items"."Warehouse ID" 
LEFT JOIN "Stock In Flow Table" ON "Stock In Flow Table"."Warehouse ID"  = "Warehouses"."Warehouse ID"  
WHERE	 "Purchase Receive Items"."Purchase Receive ID"  IS NOT NULL
UNION ALL
 SELECT
		 "Items"."Item ID" as "Item ID",
		 "Items"."Item Name" as "Item Name",
		 (		SELECT "Warehouses"."Warehouse Name"
		FROM  "Warehouses" 
		WHERE	 "Created Time"  in
			(
 			SELECT min("Created Time")
			FROM  "Warehouses" 
			)
),
		 "Items"."Created Time",
		 "Items"."Opening Stock" as "Quantity In",
		 0 as "Quantity Out",
		 0 as "Committed Stock",
		 'Initial Stock' as 'Type',
		 null
FROM  "Items" 
WHERE	 "Product Category"  NOT LIKE 'Service' /* we don't want to include non-inventory items, like services, in our counts */

UNION ALL
 SELECT
		 "Credit Note Items"."Product ID" as "Item ID",
		 "Credit Note Items"."Item Name" as "item name",
		 "Warehouses"."Warehouse Name" as "Warehouse ID",
		 "Credit Note Items"."Created Time",
		 "Credit Note Items"."Quantity",
		 0 as "Quantity Out",
		 0 as "Committed Stock",
		 'Credit Note Item' as 'Type',
		 null
FROM  "Credit Note Items"
LEFT JOIN "Credit Notes" ON "Credit Note Items"."CreditNotes ID"  = "Credit Notes"."CreditNotes ID" 
LEFT JOIN "Warehouses" ON "Warehouses"."Warehouse ID"  = "Credit Note Items"."Warehouse ID"  
WHERE	 "Credit Notes"."Credit Note Status"  not in ( 'Draft'  , 'Void'  )
UNION ALL
 SELECT
		 "Invoice Items"."Product ID" as "Item ID",
		 "Invoice Items"."Item Name" as "Item Name",
		 "Warehouses"."Warehouse Name" as "Warehouse ID",
		 "Invoice Items"."Created Time",
		 0 as "Quantity In",
		 "Invoice Items"."Quantity" as "Quantity Out",
		 0 as "Committed Stock",
		 'Invoice Item' as 'Type',
		 null
FROM  "Invoice Items"
LEFT JOIN "Invoices" ON "Invoice Items"."Invoice ID"  = "Invoices"."Invoice ID" 
LEFT JOIN "Items" ON "Items"."Item ID"  = "Invoice Items"."Product ID" 
LEFT JOIN "Warehouses" ON "Warehouses"."Warehouse ID"  = "Invoice Items"."Warehouse ID"  
WHERE	 "Invoices"."Invoice Status"  not in ( 'Draft'  , 'Void'  )
 AND	"Items"."Product Category"  NOT LIKE 'Service' /* the line above is meant to exclude non-final invoices and items that are non-inventory
Also, you could just as easily account for inventory leaving based off of packages, if your business ALWAYS uses them */

UNION ALL
 SELECT
		 "Vendor Credit Items"."Product ID",
		 "Vendor Credit Items"."Item Name",
		 "Vendor Credit Items"."Warehouse ID",
		 "Vendor Credit Items"."Created Time",
		 0 as "Quantity In",
		 "Vendor Credit Items"."Quantity" as "Quantity Out",
		 0 as "Committed Stock",
		 'Vendor Credit Item' as 'Type',
		 null
FROM  "Vendor Credit Items"
JOIN "Vendor Credits" ON "Vendor Credits"."Vendor Credit ID"  = "Vendor Credit Items"."Vendor Credit ID"  
UNION ALL
 SELECT
		 "Inventory Adjustment Items"."Product ID",
		 "Inventory Adjustment Items"."Inventory Adjustment Item ID",
		 "Inventory Adjustment Items"."Warehouse ID",
		 "Inventory Adjustment Items"."Created Time",
		 if("Inventory Adjustment Items"."Quantity Adjusted"  > 0, "Inventory Adjustment Items"."Quantity Adjusted", 0) as "Quantity In",
		 if("Inventory Adjustment Items"."Quantity Adjusted"  < 0, -1 * "Inventory Adjustment Items"."Quantity Adjusted", 0) as "Quantity Out",
		 0 as "Committed Stock",
		 'Inventory Adjustment Item' as 'Type',
		 null
FROM  "Inventory Adjustment Items" 
UNION ALL
 SELECT
		 "Sales Order Items"."Product ID",
		 "Sales Order Items"."Item Name",
		 "Sales Order Items"."Warehouse ID",
		 "Sales Order Items"."Created Time",
		 0 as "Quantity In",
		 0 as "Quantity Out",
		 "Sales Order Items"."Quantity" as "Committed Stock",
		 'Sales Order Item' as 'Type',
		 null
FROM  "Sales Order Items"
LEFT JOIN "Sales Orders" ON "Sales Orders"."Sales order ID"  = "Sales Order Items"."Sales order ID" 
LEFT JOIN "Items" ON "Items"."Item ID"  = "Sales Order Items"."Product ID"  
WHERE	 "Sales Orders"."Status"  NOT IN ( 'void'  , 'invoiced'  )
 AND	"Items"."Product Category"  NOT LIKE 'Service'
 
 
 
 
 
 
