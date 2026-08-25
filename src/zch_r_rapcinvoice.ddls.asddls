@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Invoice Root View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZCH_R_RAPCInvoice
  as select from zch_dmo_invoice
  composition [0..*] of ZCH_I_RAPCPosition as _Position
{
  key document as Document,
      doc_date as DocDate,
      doc_time as DocTime,
      partner  as Partner,

      _Position
}
