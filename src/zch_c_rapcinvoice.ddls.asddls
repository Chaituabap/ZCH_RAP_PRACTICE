@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View for RAP Invoice'
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZCH_C_RAPCInvoice 
provider contract transactional_query
as projection on ZCH_R_RAPCInvoice as Invoice
{
    @Search.defaultSearchElement: true
    @Search.fuzzinessThreshold: 1.0
    key Document,
    DocDate,
    DocTime,
    @Search.defaultSearchElement: true
    @Search.fuzzinessThreshold: 0.8
    Partner,
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_CH_DEMO_CRAP_VE_EXIT'
    virtual NumberOfPositions : abap.int4,
    /* Associations */
    _Position : redirected to composition child ZCH_C_RAPCPosition
}
