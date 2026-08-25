@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for Position'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZCH_I_RAPCPosition
  as select from zch_dmo_position
  association     to parent ZCH_R_RAPCInvoice as _Invoice  on $projection.Document = _Invoice.Document
  association [1] to ZCH_I_RAPCMaterial       as _Material on $projection.Material = _Material.Material
{
  key document            as Document,
  key pos_number          as PositionNumber,
      material            as Material,
      @Semantics.quantity.unitOfMeasure: 'Unit'
      quantity            as Quantity,
      _Material.StockUnit as Unit,
      @Semantics.amount.currencyCode: 'Currency'
      price               as Price,
      currency            as Currency,

      _Invoice

}
