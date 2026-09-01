@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View for RAP Invoice'
@Metadata.allowExtensions: true
define root view entity ZCH_C_RAPCInvoice 
provider contract transactional_query
as projection on ZCH_R_RAPCInvoice as Invoice
{
    key Document,
    DocDate,
    DocTime,
    Partner,
    /* Associations */
    _Position : redirected to composition child ZCH_C_RAPCPosition
}
