public with sharing class WarehouseCalloutService {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
    // complete this method to make the callout (using @future) to the
    // REST endpoint and update equipment on hand.
    @future(callout=true)
    public static void runWarehouseEquipmentSync(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200) {
        	List<Object> results = (List<Object>)JSON.deserializeUntyped(response.getBody());
        	
        	Map<String, Product2> equipmentsFromService = new Map<String, Product2>();
        	for(Object equipment: results) {
        		Map<String, Object> mapobj = (Map<String, Object>)equipment;
        		Product2 eq = new Product2();
        		String sku = (String)mapobj.get('sku');   
        		eq.Name =   (String)mapobj.get('name');    
        		eq.Warehouse_SKU__c = sku;
        		eq.Replacement_Part__c = (Boolean)mapobj.get('replacement');//Boolean.valueOf((String)mapobj.get('replacement'));	
        		eq.Current_Inventory__c = (Integer)mapobj.get('quantity');
        		eq.Maintenance_Cycle__c = (Integer)mapobj.get('maintenanceperiod');
        		eq.Lifespan_Months__c = (Integer)mapobj.get('lifespan');
        		eq.Cost__c = (Integer)mapobj.get('cost');
        		equipmentsFromService.put(sku, eq);   		
        	}
        	
        	Map<Id, Product2> tempList = new Map<Id, Product2>([SELECT Id, Name, Warehouse_SKU__c, Replacement_Part__c,
        																	Current_Inventory__c, Maintenance_Cycle__c,
        																	Lifespan_Months__c, Cost__c
        																	FROM Product2
        																	WHERE Warehouse_SKU__c IN :equipmentsFromService.keySet()]); 
        	
        	Map<String, Product2> toUpdateList = new Map<String, Product2>();
        	for(Id key: tempList.keySet()) { 		
        		Product2 p = tempList.get(key);
        		toUpdateList.put(p.Warehouse_SKU__c, p);		
        	}
        	      	
        	List<Product2> equipments = new List<Product2>();
        	for(String key: equipmentsFromService.keySet()) {
        		Product2 pDestination;
        		if(toUpdateList.containsKey(key)) {
        			pDestination = toUpdateList.get(key);
        			Product2 pSource = equipmentsFromService.get(key);
        			pDestination.Name = pSource.Name;
        			pDestination.Warehouse_SKU__c = pSource.Warehouse_SKU__c;
        			pDestination.Replacement_Part__c = pSource.Replacement_Part__c;
        			pDestination.Current_Inventory__c = pSource.Current_Inventory__c;
        			pDestination.Maintenance_Cycle__c = pSource.Maintenance_Cycle__c;
        			pDestination.Lifespan_Months__c = pSource.Lifespan_Months__c;
        			pDestination.Cost__c = pSource.Cost__c;
        		}
        		else {
        			pDestination = equipmentsFromService.get(key);
        		}
        		equipments.Add(pDestination);
        	}
        	
        	if(equipments.size() > 0)  upsert equipments;
        }
    }

}