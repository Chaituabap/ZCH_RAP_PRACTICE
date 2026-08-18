@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RAP interface for Partner'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZCH_I_RAPPartner
  as select from zch_dmo_partner
{

  key partner          as PartnerNumber,
      name             as PartnerName,
      street           as Street,
      city             as City,
      country          as Country,
      payment_currency as PaymentCurrency
}
