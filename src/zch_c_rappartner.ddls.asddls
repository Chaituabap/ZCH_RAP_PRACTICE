@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RAP Projection for Partner'
@Metadata.allowExtensions: true
define root view entity ZCH_C_RAPPartner
  provider contract transactional_query
  as projection on ZCH_I_RAPPartner
{
  key PartnerNumber,
      PartnerName,
      Street,
      City,
      Country,
      PaymentCurrency,
      LastChangedAt,
      LastChangedBy,
      CreatedAt,
      CreatedBy,
      LocalLastChangedAt
}
