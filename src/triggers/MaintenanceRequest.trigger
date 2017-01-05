trigger MaintenanceRequest on Case (after update, after insert) {
    //todo: call MaintenanceRequestHelper.updateWorkOrders  
    MaintenanceRequestHelper.updateWorkOrders(Trigger.newMap);
}