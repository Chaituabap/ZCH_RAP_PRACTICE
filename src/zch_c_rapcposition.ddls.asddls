@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View for RAP Position'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZCH_C_RAPCPosition 
 as projection on ZCH_I_RAPCPosition as Position
{
    key Document,
    key PositionNumber,
    Material,
    @Semantics.quantity.unitOfMeasure: 'Unit'
    Quantity,
    Unit,
    @Semantics.amount.currencyCode: 'Currency'
    Price,
    Currency,
    /* Associations */
    _Invoice :redirected to parent ZCH_C_RAPCInvoice
}
