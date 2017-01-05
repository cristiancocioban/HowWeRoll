public class MaintenanceRequestHelper {
    public static void updateWorkOrders(Map<Id, Case> mapMaintanceRequests){
        
        List<Case> maintanceRequests = [SELECT Id, Subject, CreatedDate, Status, Vehicle__c,
        									   Equipment__c, Type, (SELECT Id, Name, Equipment__r.Maintenance_Cycle__c FROM Work_Parts__r)
        							    FROM Case WHERE Id in :mapMaintanceRequests.keySet()];
        
        List<Case> newRequests = new List<Case>();
		for(Case c: maintanceRequests) {
			if(c.Type == 'Repair' || c.Type == 'Routine Maintenance') {
				if(c.Status == 'Closed') {
					Case newCase = new Case();
					newCase.Subject = 'Routine Maintenance';
					if(c.Subject != null) newCase.Subject = c.Subject;
					newCase.Date_Reported__c = c.CreatedDate.date();
					newCase.Vehicle__c = c.Vehicle__c;
					newCase.Equipment__c = c.Equipment__c;
					newCase.Date_Due__c = calculateNextDueDate(c);
					newCase.Type = 'Routine Maintenance';
					newRequests.Add(newCase);
				}
			}
		}
		
		insert newRequests;
    }        
    
    private static Date calculateNextDueDate(Case c) {
    	Date minDate = null;
    	for(Work_Part__c wp: c.Work_Parts__r) { 
    		Date lifespan = Date.today().addMonths(Integer.valueof(wp.Equipment__r.Maintenance_Cycle__c.round(System.RoundingMode.DOWN)));
    		
    		if(minDate == null) minDate = lifespan;
    		else if(minDate > lifespan) minDate = lifespan; 
    	}
    	
    	return minDate;
    }
}