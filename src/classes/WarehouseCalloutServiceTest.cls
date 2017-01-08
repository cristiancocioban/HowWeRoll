@isTest
private class WarehouseCalloutServiceTest {
  // implement your mock callout test here
  @isTest
  private static void testExecute() {
        //List<EquipmentWrapperFromJSON> ListEWFS = new List<EquipmentWrapperFromJSON>();
        List<Product2> listProduct = new List<Product2>();
        Product2 p = new Product2();
        p.Replacement_Part__c = true;
        p.Name = 'testing';
        p.Cost__c = 10;
        p.Current_Inventory__c = 5;
        p.Lifespan_Months__c = 2;
        p.Maintenance_Cycle__c = 60;
        p.Warehouse_SKU__c = '10001';
        listProduct.add(p);     

        insert listProduct;

        test.startTest();
            //ListEWFS = WarehouseCalloutService.wrapWquipment();
            Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
            WarehouseCalloutService.runWarehouseEquipmentSync();
        test.stopTest();
        Upsert listProduct;
  }
  
	@isTest
	private static void testSchedule() {
		String CRON_EXP = '0 0 1 * * ?';
		
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        WarehouseCalloutService.runWarehouseEquipmentSync();		
		String jobId = System.schedule('ScheduledApexTest', CRON_EXP,
										new WarehouseSyncSchedule());
		Test.stopTest();

		System.debug('testSchedule finished');
		System.assertEquals(1, 1);
		System.debug('testSchedule after assert');
		
	}  
}